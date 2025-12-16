module KeyDebounce #(
    parameter CLK_FREQ = 50_000_000,  // 时钟频率(Hz), 50 MHz
    parameter KEY_CNT = 8             // 按键数量
) (
    input clk,                        // 时钟输入
    input [KEY_CNT-1:0] keys,         // 原始按键输入，可能有抖动
    output reg [KEY_CNT-1:0] keys_stable = {KEY_CNT{1'b1}}  // 消抖后的稳定输出
);

// ==================== 状态机状态定义 ====================
// 使用二进制编码定义两个状态
parameter STATE_IDLE     = 1'b0;      // 空闲状态：等待按键变化
parameter STATE_SAMPLING = 1'b1;      // 采样状态：等待20ms稳定

// 状态寄存器
reg current_state = STATE_IDLE;       // 当前状态寄存器
reg next_state = STATE_IDLE;          // 下一状态寄存器

// ==================== 中间信号定义 ====================
// 20ms计数器相关信号
parameter KEY_CLK_MAX = CLK_FREQ * 20 / 1000 - 1;  // 20ms所需的时钟周期数
reg [31:0] key_clk_cnt = 32'b0;                   // 20ms计数器
wire key_sampling_finished;                       // 20ms采样完成标志
assign key_sampling_finished = (key_clk_cnt >= KEY_CLK_MAX);  // 计数器达到最大值时完成

// 按键变化检测相关信号
reg [KEY_CNT-1:0] key_prev = {KEY_CNT{1'b1}};     // 上一周期的按键状态
wire [KEY_CNT-1:0] key_change;                    // 按键变化检测信号
assign key_change = keys ^ key_prev;               // 异或操作检测变化

// ==================== 状态机第一段：状态寄存器更新 ====================
// 时序逻辑：在时钟上升沿更新当前状态
always @(posedge clk) begin
    current_state <= next_state;                   // 将下一状态赋值给当前状态
end

// ==================== 状态机第二段：状态转移逻辑 ====================
// 组合逻辑：根据当前状态和输入决定下一状态
always @(*) begin
    case (current_state)
        STATE_IDLE: begin
            if (|key_change) begin                 // 如果有按键变化（key_change不为0）
                next_state = STATE_SAMPLING;       // 进入采样状态
            end
            else begin
                next_state = STATE_IDLE;           // 否则保持空闲状态
            end
        end
        
        STATE_SAMPLING: begin
            if (key_sampling_finished) begin       // 如果20ms采样完成
                next_state = STATE_IDLE;           // 返回空闲状态
            end
            else begin
                next_state = STATE_SAMPLING;       // 否则保持采样状态
            end
        end
        
        default: begin
            next_state = STATE_IDLE;               // 默认状态为空闲
        end
    endcase
end

// ==================== 状态机第三段：输出逻辑和计数器更新 ====================
// 时序逻辑：更新计数器和控制输出

// 更新20ms计数器
always @(posedge clk) begin
    if (current_state == STATE_IDLE || (|key_change)) begin
        // 在空闲状态或按键变化时，计数器清零
        key_clk_cnt <= 32'b0;
    end
    else if (current_state == STATE_SAMPLING) begin
        // 在采样状态且未完成时，计数器递增
        key_clk_cnt <= key_clk_cnt + 32'b1;
    end
end

// 更新上一周期的按键状态
always @(posedge clk) begin
    key_prev <= keys;                             // 保存当前按键状态供下一周期比较
end

// 更新稳定的按键输出
always @(posedge clk) begin
    // 当从采样状态返回空闲状态时，更新稳定输出
    if (current_state == STATE_SAMPLING && next_state == STATE_IDLE) begin
        keys_stable <= key_prev;                   // 使用20ms前稳定的按键状态
    end
end

endmodule