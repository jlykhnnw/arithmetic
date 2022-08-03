//wk2021/06/10/20:00
module DividerUintRound32z17d #(
  parameter Z_L = 32,
  parameter D_L = 17
)(
  input  wire Clk_i		          ,
  input  wire Rst_n_i	          ,
  input  wire Start_i	          ,
  input	 wire [Z_L-1:0]Z        ,
  input	 wire [D_L-1:0]D        ,
  output wire [Z_L-D_L:0] Q_out ,
  output  reg	Finish_o
);

reg 						Start_i_syn;
reg	[4:0]				counter;
reg [Z_L-1:0] 	Z_reg;
reg [Z_L-1:0] 	D_reg;
reg [Z_L-D_L:0] Q		 ;

always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Start_i_syn <= 1'b0;
	else
		Start_i_syn <= Start_i;
end

reg Start_i_syn_reg1;
reg Start_i_syn_reg2;
always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Start_i_syn_reg1 <= 1'b0;
	else
		Start_i_syn_reg1 <= Start_i_syn;
end
always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Start_i_syn_reg2 <= 1'b0;
	else
		Start_i_syn_reg2 <= Start_i_syn_reg1;
end


always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		counter <= 31;
	else if(Start_i_syn)
		counter <= 0;
	else if(counter < 31)
		counter <= counter + 1;
	else;
end

//Z_reg
always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Z_reg[Z_L-1:0] <= {Z_L{1'b0}};
	else if(counter == 1 && Start_i_syn_reg2)
		Z_reg[Z_L-1:0] <= Z[Z_L-1:0];
	else if(counter >= 2 && counter <= Z_L-D_L+2)
		if(Z_reg[Z_L-1:0]>=D_reg[Z_L-1:0])
			Z_reg[Z_L-1:0] <= Z_reg[Z_L-1:0] - D_reg[Z_L-1:0];
		else;		
	else;
end

//D_reg
always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		D_reg[Z_L-1:0] <= {Z_L{1'b0}};
	else if(counter == 1 && Start_i_syn_reg2)
		D_reg[Z_L-1:0] <= { D[D_L-1:0], {(Z_L-D_L){1'b0}} };
	else if(counter >= 2 && counter <= Z_L-D_L+2)
		D_reg[Z_L-1:0] <= {1'b0, D_reg[Z_L-1:1]};
	else;
end

//Q
wire 	 [D_L-1:0] D_div2 = D >> 1;
always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Q[Z_L-D_L:0] <= {(Z_L-D_L+1){1'b0}};
	else if(counter >= 2 && counter <= Z_L-D_L+2)
		if(Z_reg[Z_L-1:0]>=D_reg[Z_L-1:0])
			Q[Z_L-D_L+2-counter] <= 1'b1;
		else
			Q[Z_L-D_L+2-counter] <= 1'b0;
	else if(counter == Z_L-D_L+3)
		Q <= (Z_reg > D_div2)? Q+1 : Q;
	else;
end
assign Q_out = Q;

//Finish_o
always @(posedge Clk_i or negedge Rst_n_i) begin
	if(~Rst_n_i)
		Finish_o <= 1'b0;
	else if(counter == Z_L-D_L+3)
		Finish_o <= 1'b1;
	else
		Finish_o <= 1'b0;
end

endmodule
