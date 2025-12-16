module Core(
   // clock input
   input               clk,
   // system reset, low active
   input               rstn,
   // BRAM read interface
   output  [9:0]       bram_rd_addr,
   input   [7:0]       bram_rd_data,
   // detection control signals
   input               detect_start,
   output              detect_finish,
   // detection result related signals
   output  [2:0]       detect_peak_num,
   input   [2:0]       disp_peak_idx,
   output  [4:0]       disp_peak_row,
   output  [4:0]       disp_peak_col,  
   output  [7:0]       disp_peak_val
);

// TODO - implement core detection logic here
//      -  following code NEED TO REMOVE IN YOUR CODE

//////////////// check detect_start rising edge ////////////////
reg detect_start_d1 = 1'b0; // detect_start with 1 clock delay

always @(posedge clk) begin
   if (~rstn) begin
      detect_start_d1 <= 1'b0;
   end 
   else begin
      detect_start_d1 <= detect_start;
   end 
end

wire detect_new_request;
assign detect_new_request = detect_start & (~detect_start_d1);
////////////////////////////////////////////////////////////////

// TODO - remove wait_cnt related code, which for simulate detection process only
//       and replace with actual detection logic
reg [15:0] wait_cnt = 16'd0;

always @(posedge clk) begin
   if (~rstn || detect_new_request) begin
      wait_cnt <= 16'b0;
   end 
   else if (detect_start && wait_cnt != 16'hff_ff) begin
      wait_cnt <= wait_cnt + 16'd1;
   end 
end 
////////////////////////////////////////////////////////////////

// TODO - set to actual finish signal
assign detect_finish = (wait_cnt == 16'hff_ff); 
////////////////////////////////////////////////////////////////

// TODO - set to actual detected peak number
assign detect_peak_num = detect_finish ? 3'd6 : 3'b0; 
////////////////////////////////////////////////////////////////

// TODO - set to actual detected peak data
reg  [4:0]       disp_peak_row_r = 5'b0;
reg  [4:0]       disp_peak_col_r = 5'b0;  
reg  [7:0]       disp_peak_val_r = 8'b0;

assign disp_peak_row = disp_peak_row_r;
assign disp_peak_col = disp_peak_col_r;
assign disp_peak_val = disp_peak_val_r;

always @(*) begin
   if (~rstn || ~detect_finish) begin
      disp_peak_row_r <= 5'b0;
      disp_peak_col_r <= 5'b0;
      disp_peak_val_r <= 8'b0;
   end 
   else begin
      case (disp_peak_idx)
         3'd0: begin
            disp_peak_row_r <= 5'd10;
            disp_peak_col_r <= 5'd15;
            disp_peak_val_r <= 8'd120;
         end 
         3'd1: begin
            disp_peak_row_r <= 5'd12;
            disp_peak_col_r <= 5'd18;
            disp_peak_val_r <= 8'd100;
         end 
         3'd2: begin
            disp_peak_row_r <= 5'd14;
            disp_peak_col_r <= 5'd20;
            disp_peak_val_r <= 8'd80;
         end 
         3'd3: begin
            disp_peak_row_r <= 5'd16;
            disp_peak_col_r <= 5'd25;
            disp_peak_val_r <= 8'd60;
         end 
         3'd4: begin
            disp_peak_row_r <= 5'd18;
            disp_peak_col_r <= 5'd30;
            disp_peak_val_r <= 8'd40;
         end 
         3'd5: begin
            disp_peak_row_r <= 5'd10;
            disp_peak_col_r <= 5'd31;
            disp_peak_val_r <= 8'd99;
         end
         default: begin
            disp_peak_row_r <= 5'b0;
            disp_peak_col_r <= 5'b0;
            disp_peak_val_r <= 8'b0;
         end 
      endcase
   end 
end 
////////////////////////////////////////////////////////////////

// TODO - set to actual read address
assign bram_rd_addr = 10'b0; 
////////////////////////////////////////////////////////////////

endmodule