
`include "./weprom.v"
`timescale 1ns/1ns
`define clk_cycle 10 

module weprom_tst ();

reg clk_tst;
reg rst_n_tst;
reg cs_tst;
reg address_tst;

reg data_tst;

wire ack_tst;
wire sda_tst;
wire sda_clk_tst;
wire out_vaild_tst;
 weprom isim(
	. clk(clk_tst),
	. rst_n(rst_n_tst),
	. cs(cs_tst),
	. address(address_tst),
	. data(data_tst),
	.out_vaild(out_vaild_tst),
	.ack(ack_tst),
	.sda(sda_tst),
	.sda_clk(sda_clk_tst)
);

always #`clk_cycle clk_tst = ~ clk_tst;

initial begin
	$display("Start Running  weprom Testbench !");
	
	clk_tst = 0;
	rst_n_tst = 0;
	cs_tst = 0;
	address_tst = 0;
	data_tst = 0;
	#55 
	rst_n_tst = 1;
	cs_tst = 1;
	#50
	address_tst = 1 ; //0bit
	data_tst = 0 ; 
	#20
	address_tst = 0 ; //1bit
	data_tst = 1 ;
	#20
	address_tst = 1 ; //2bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //3bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //4bit
	data_tst = 1 ;
	cs_tst = 0;
	#200
	cs_tst = 1;
	#40
	address_tst = 1 ; //5bit
	data_tst = 1 ;
	#20
	address_tst = 0 ; //6 bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //7 bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //7 bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //7 bit
	data_tst = 1 ;//-----
	#20
	address_tst = 1 ; //7 bit
	data_tst = 1 ;
	#20
	address_tst = 0 ; //7 bit
	data_tst = 1 ;
	#20
	address_tst = 1 ; //7 bit
	data_tst = 1 ;
	#20
	address_tst = 1 ; //7 bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //7 bit
	data_tst = 0 ;
	#20
	address_tst = 0; //7 bit
	data_tst = 0 ;
	#20
	address_tst = 1 ; //7 bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //7 bit
	data_tst = 1 ;
	#20

	//add 1010_0101, 
	//data 1011_0010
	#40
	cs_tst = 0;
	
	#1000
	cs_tst = 1;
	#5
	address_tst = 1 ; //0bit
	data_tst = 1 ; 
	#20
	address_tst = 1 ; //1bit
	data_tst = 1 ;
	#20
	address_tst = 1 ; //2bit
	data_tst = 1 ;
	#20
	address_tst = 1 ; //3bit
	data_tst = 1 ;
	#20
	address_tst = 0 ; //4bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //5bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //6 bit
	data_tst = 0 ;
	#20
	address_tst = 0 ; //7 bit
	data_tst = 0 ;
	#40
	cs_tst = 0;
	//add 1010_0101, 
	//data 1011_0010
	//#400
//	cs_tst = 1;
	//$stop;

end

endmodule
