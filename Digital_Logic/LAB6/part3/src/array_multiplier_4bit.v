module array_multiplier_4bit (
    input  [3:0] A,
    input  [3:0] B,
    output [7:0] P
);

	// partial products
	wire p00, p01, p02, p03;
	wire p10, p11, p12, p13;
	wire p20, p21, p22, p23;
	wire p30, p31, p32, p33;
	
	assign p00 = A[0] & B[0];
	assign p01 = A[1] & B[0];
	assign p02 = A[2] & B[0];
	assign p03 = A[3] & B[0];
	
	assign p10 = A[0] & B[1];
	assign p11 = A[1] & B[1];
	assign p12 = A[2] & B[1];
	assign p13 = A[3] & B[1];
	
	assign p20 = A[0] & B[2];
	assign p21 = A[1] & B[2];
	assign p22 = A[2] & B[2];
	assign p23 = A[3] & B[2];
	
	assign p30 = A[0] & B[3];
	assign p31 = A[1] & B[3];
	assign p32 = A[2] & B[3];
	assign p33 = A[3] & B[3];
	
	// sums
	wire s10, s11, s12, s13;
	wire s20, s21, s22, s23;
	wire s30, s31, s32, s33;
	
	// carry outs
	wire c10, c11, c12, c13;
	wire c20, c21, c22, c23;
	wire c30, c31, c32, c33;
		
	fa fa10 (.A(p01) , .B(p10), .C_in(1'b0), .S(s10), .C_out(c10));
	fa fa11 (.A(p02) , .B(p11), .C_in(c10) , .S(s11), .C_out(c11));
	fa fa12 (.A(p03) , .B(p12), .C_in(c11) , .S(s12), .C_out(c12));
	fa fa13 (.A(1'b0), .B(p13), .C_in(c12) , .S(s13), .C_out(c13));

	fa fa20 (.A(s11), .B(p20), .C_in(1'b0), .S(s20), .C_out(c20));
	fa fa21 (.A(s12), .B(p21), .C_in(c20) , .S(s21), .C_out(c21));
	fa fa22 (.A(s13), .B(p22), .C_in(c21) , .S(s22), .C_out(c22));
	fa fa23 (.A(c13), .B(p23), .C_in(c22) , .S(s23), .C_out(c23));
	
	fa fa30 (.A(s21), .B(p30), .C_in(1'b0), .S(s30), .C_out(c30));
	fa fa31 (.A(s22), .B(p31), .C_in(c30) , .S(s31), .C_out(c31));
	fa fa32 (.A(s23), .B(p32), .C_in(c31) , .S(s32), .C_out(c32));
	fa fa33 (.A(c23), .B(p33), .C_in(c32) , .S(s33), .C_out(c33));
	
	assign P[0] = p00;
	assign P[1] = s10;
	assign P[2] = s20;
	assign P[3] = s30;
	assign P[4] = s31;
	assign P[5] = s32;
	assign P[6] = s33;
	assign P[7] = c33;
	
endmodule