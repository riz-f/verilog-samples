module top
(
   input clk,

   output reg [6:0] led,

   input enc_a,
   input enc_b,
   input enc_btn
);

wire n_enc_btn = ~enc_btn;
	
wire enc_a_db;
wire enc_b_db;
wire enc_btn_db;
  
wire enc_a_rise;
wire enc_b_rise;
wire enc_btn_rise;

wire enc_a_fall;
wire enc_b_fall;
wire enc_btn_fall;

debounce
(
	.clk(clk),
	.switch_in(enc_a),
	.switch_out(enc_a_db),
	.switch_rise(enc_a_rise),
	.switch_fall(enc_a_fall)
);

debounce
(
	.clk(clk),
	.switch_in(enc_b),
	.switch_out(enc_b_db),
	.switch_rise(enc_b_rise),
	.switch_fall(enc_b_fall)
);

reg [3:0] enc_byte = 0;
always @(posedge clk)
begin
	if (n_enc_btn == 1)
		enc_byte <= 0;
	else
		if (enc_a_rise)
			if (!enc_b_db)
				enc_byte <= enc_byte != 0 ? enc_byte - 1 : 0;
			else
				enc_byte <= enc_byte + 1;
end

always @(posedge clk)
begin
    case (enc_byte)
      0: led <= 7'b1111110;
      1: led <= 7'b0110000;
      2: led <= 7'b1101101;
      3: led <= 7'b1111001;
      4: led <= 7'b0110011;
      5: led <= 7'b1011011;
      6: led <= 7'b1011111;
      7: led <= 7'b1110000;
      8: led <= 7'b1111111;
      9: led <= 7'b1110011;
      10: led <= 7'b1110111;
      11: led <= 7'b0011111;
      12: led <= 7'b1001110;
      13: led <= 7'b0111101;
      14: led <= 7'b1001111;
      15: led <= 7'b1000111;
    endcase
end

endmodule