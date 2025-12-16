`define BRAM_WR_DEBUG
`define SEG_SEL_NULL  4'b0000
`define SEG_SEL_0     4'b0001
`define SEG_SEL_1     4'b0010
`define SEG_SEL_2     4'b0100
`define SEG_SEL_3     4'b1000

module SegWrapper #(
   parameter CLK_FREQ = 50_000_000,
   parameter SEG_FLASH_DUR = 49_999
) (
   input                            clk,
   input                            rstn,
   input      [1:0]                 disp_mode, 
   input      [12:0]                detect_time,
   input      [2:0]                 disp_peak_idx,
   input      [4:0]                 disp_peak_row,
   input      [4:0]                 disp_peak_col,
   input      [7:0]                 disp_peak_val,
   output  reg[3:0]                 seg_sel,
   output  reg[7:0]                 seg_data
);

// TODO - implement 7-segments tube display logic here
//动态扫描
reg[19:0]scan_cnt=20'd0;//计数器

always @(posedge clk) begin
   if(~rstn)begin//按下--复位
      scan_cnt<=20'd0;
   end
   else begin
      scan_cnt<=scan_cnt+20'd1;
   end
end

always @(posedge clk) begin//选择数码管，动态扫描
   if(~rstn)begin
      seg_sel<=4'b0001;
   end
   else if(scan_cnt==SEG_FLASH_DUR) begin
      seg_sel<={seg_sel[2:0],seg_sel[3]};
   end
end

reg[3:0]display_numbers[0:3];//4个数码管，每个数码管的数字按照4位2进制数储存

always @(*) begin
   case (disp_mode)
      2'b00: begin // 未完成，显示全0
         display_numbers[0] = 4'd0;
         display_numbers[1] = 4'd0;
         display_numbers[2] = 4'd0;
         display_numbers[3] = 4'd0;
      end
      2'b01: begin // 显示时间
         display_numbers[0] = detect_time/1000;           // 千位
         display_numbers[1] = (detect_time%1000)/100;  // 百位
         display_numbers[2] = (detect_time%100)/10;    // 十位
         display_numbers[3] = detect_time%10;            // 个位
      end
      2'b10: begin // 显示坐标（行和列）
         display_numbers[0] = disp_peak_row / 10;  // 行十位
         display_numbers[1] = disp_peak_row % 10;  // 行个位
         display_numbers[2] = disp_peak_col / 10;  // 列十位
         display_numbers[3] = disp_peak_col % 10;  // 列个位
      end
      2'b11: begin // 显示峰值数值
         display_numbers[0] = disp_peak_val/1000; // 
         display_numbers[1] = (disp_peak_val/100)%10;           // 百位
         display_numbers[2] = (disp_peak_val%100)/10;    // 十位
         display_numbers[3] = disp_peak_val%10;            // 个位
      end
      default: begin
         display_numbers[0] = 4'd0;
         display_numbers[1] = 4'd0;
         display_numbers[2] = 4'd0;
         display_numbers[3] = 4'd0;
      end
   endcase 
end

reg[7:0]seg_table[0:15];

always @(*) begin
   seg_table[0] = 8'h3f;  // 0
   seg_table[1] = 8'h06;  // 1
   seg_table[2] = 8'h5b;  // 2
   seg_table[3] = 8'h4f;  // 3
   seg_table[4] = 8'h66;  // 4
   seg_table[5] = 8'h6d;  // 5
   seg_table[6] = 8'h7d;  // 6
   seg_table[7] = 8'h07;  // 7
   seg_table[8] = 8'h7f;  // 8
   seg_table[9] = 8'h6f;  // 9
   seg_table[10] = 8'h77; // A（用于十六进制，这里十进制不用）
   seg_table[11] = 8'h7c; // B
   seg_table[12] = 8'h39; // C
   seg_table[13] = 8'h5e; // D
   seg_table[14] = 8'h79; // E
   seg_table[15] = 8'h71; // F
end

// ==================== 段选信号生成 ====================
always @(posedge clk) begin
   if (~rstn) begin
      seg_data <= 8'h00;
   end 
   else begin
      case (seg_sel)
         4'b0001: seg_data <= seg_table[display_numbers[0]];
         4'b0010: seg_data <= seg_table[display_numbers[1]];
         4'b0100: seg_data <= seg_table[display_numbers[2]];
         4'b1000: seg_data <= seg_table[display_numbers[3]];
         default: seg_data <= 8'h00;
      endcase
   end
end

endmodule