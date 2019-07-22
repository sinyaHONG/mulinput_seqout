/*简化的 EPROM 的串行写入器
*工作的步骤是：
*	0. cs 拉高 
*	1.地址的串行写入；8b : 12'b 1000_****_****  msb ->lsb
*	2.数据的串行写入；8b : 12'b 1000_****_****
*   3. cs 拉低
*	3.给信号源应答，信号源给出下一个操作对象；
*	4.结束写操作。
*   5.通过移位令并行数据得以一位一位输出。
*/
module weprom(
	input clk,
	input rst_n,
	input cs,
	input  address,
	input  data,
	
	output wire ack,
	output wire out_vaild,
	output reg sda,
	output reg sda_clk
);

parameter IDLE = 4'd0;
//parameter W_ADD= 4'd1;
//parameter W_DATA= 4'd2;
parameter OUT_SDA= 4'd2;
 
 
parameter ADD_REV= 4'd1;
parameter ADD_JUDGE= 4'd2;

reg [3:0] add_in_state;

parameter DATA_REV= 4'd1;
parameter DATA_JUDGE= 4'd2;

reg [3:0] data_in_state;
reg  data_in_r0; 
reg  data_in_r1;
reg [11:0] data_buf; 
reg [7:0] data_in_bit; 
reg data_in_ack;

reg  add_in_r0; 
reg  add_in_r1;
reg [7:0] add_in_bit; 
reg [11:0] add_buf;
reg add_in_ack;


reg input_ack;
reg [3:0] out_state;

reg [7:0] data_out_bit; 
/*
always @(posedge clk) begin
	add_in_r0 <= address;
	add_in_r1 <= add_in_r0;
	
	data_in_r0 <= data;
	data_in_r1 <= data_in_r0;

end
*/
reg  cs_r0; 
reg  cs_r1;
wire cs_pose;
always @(posedge clk) begin
	cs_r0 <= cs;
	cs_r1 <= cs_r0;
end
assign cs_pose = cs_r0 & (~cs_r1);
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_in_bit <= 0;
		data_buf <= 8'b0;
		data_in_ack <= 'b0;
		data_in_state <= IDLE;
	end 
	else begin
		data_in_bit <= data_in_bit + 1'b1;
		case (data_in_state)
			IDLE : begin
						data_in_bit <= 8'd0;
						data_in_ack <= 'b0;
						if( cs_pose) begin	
							data_in_bit <= 12'b0;
							data_in_state <= DATA_REV;
						end
						else
							data_in_state <= IDLE;
				end 
			DATA_REV : begin
						data_in_bit <= data_in_bit + 1'b1;
						
						case(data_in_bit)	 
							8'd0  : data_buf[11] <= data ; //data_in_r1;
							8'd1  : data_buf[10] <= data ; //data_in_r1;
							8'd2  : data_buf[9] <= data ; //data_in_r1;
							8'd3  : data_buf[8] <= data ; //data_in_r1;
							8'd4  : data_buf[7] <= data ; 
							8'd5  : data_buf[6] <= data ; 
							8'd6  : data_buf[5] <= data ; 
							8'd7  : data_buf[4] <= data ; 
							8'd8  : data_buf[3] <= data ; 
							8'd9  : data_buf[2] <= data ; 
							8'd10 : data_buf[1] <= data ; 
							8'd11 : begin 
										data_buf[0] <= data ; 
										data_in_state <= DATA_JUDGE;
										
									end 
						endcase					
				end
			DATA_JUDGE : begin
						if(data_buf[11:8] == 4'b1000) 
						    data_in_ack <= 'b1;
						data_in_state <= IDLE;
				end	
		endcase
		
	end 
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		add_in_bit <= 0;
		add_buf <= 12'b0;
		add_in_ack <= 'b0;
		add_in_state <= IDLE;
	end 
	else begin
		case (add_in_state)
			IDLE : begin
						add_in_bit <= 8'd0;
						add_in_ack <= 'b0;
						if( cs_pose) begin	
						
							add_in_bit <= 12'b0;
							add_buf <= 12'b0;
							add_in_state <= ADD_REV;
						end
						else
							add_in_state <= IDLE;
				end 
			ADD_REV : begin	
						if(cs) begin
						
							add_in_bit <= add_in_bit + 'b1;
							case(add_in_bit)	 
								8'd0  : add_buf[11] <= address ; //data_in_r1;
								8'd1  : add_buf[10] <= address ; //data_in_r1;
								8'd2  : add_buf[9]  <= address ; //data_in_r1;
								8'd3  : add_buf[8]  <= address ; //data_in_r1;
								8'd4  : add_buf[7]  <= address ;
								8'd5  : add_buf[6]  <= address ;
								8'd6  : add_buf[5]  <= address ;
								8'd7  : add_buf[4]  <= address ;
								8'd8  : add_buf[3]  <= address ;
								8'd9  : add_buf[2]  <= address ;
								8'd10 : add_buf[1]  <= address ;
								8'd11 : begin 
											add_buf[0]  <= address ;
											add_in_state <= ADD_JUDGE;
										end	
							endcase
						end
						else begin
							add_in_state <= IDLE;
							add_buf <= 12'b0;
						end
				end
			ADD_JUDGE : begin
						    if(add_buf[11:8] == 4'b1000) begin
						        add_in_ack <= 'b1;
							end 
								add_in_state <= IDLE;									
						   
					end		
		endcase
		
	end 
end


assign  in_finish = (data_in_ack && add_in_ack )? 1 : 0;
assign ack = in_finish;
reg sda_vaild;
assign out_vaild = sda_vaild;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_in_bit <= 8'd0;
		data_out_bit <= 8'd0;
		input_ack <= 'b1;
		
		sda_vaild <='b0;
		out_state <= IDLE;
	end
	else begin
		data_out_bit <= data_out_bit + 'b1;	
		case (out_state)
			IDLE : begin
					data_out_bit <= 8'b0;
					sda_vaild <= 'b0;
					input_ack <= 'b1;	
						
					if(in_finish) begin
						sda_clk <= 'b0;
						out_state <= OUT_SDA;
					end
					else
						out_state <= IDLE;
						sda <= 'b0;
			
			end
			OUT_SDA : begin
					input_ack <= 'b0;
					sda_vaild <= 'b1;
					case(data_out_bit) 
						8'd0  :	begin 
									sda <= add_buf[0];
									sda_clk <= 1;
								end
								
						8'd1  :	sda_clk <= 0;
						
						8'd2  :begin
									sda <= add_buf[1];
									sda_clk <= 1;
								end
						8'd3  :	sda_clk <= 0;
						
						8'd4  :	begin
									sda <= add_buf[2];
									sda_clk <= 1;
								end 
						8'd5  :	sda_clk <= 0;	
						
						8'd6  :	begin
									sda <= add_buf[3];
									sda_clk <= 1;
								end
						8'd7  :		sda_clk <= 0;
						
						8'd8  : begin 
									sda <= add_buf[4];
									sda_clk <= 1;
								end
						8'd9  : sda_clk <= 0;
						
						8'd10 : begin
									sda <= add_buf[5];
									sda_clk <= 1;
								end
						8'd11  : sda_clk <= 0;
						
						8'd12  : begin
									sda <= add_buf[6];
									sda_clk <= 1;
								 end
						8'd13  : sda_clk <= 0;	 
						
						8'd14  : begin
									sda <= add_buf[7];
									sda_clk <= 1;
								 end
						8'd15  : sda_clk <= 0;	 	 
								 
						8'd16  :begin
									sda <= data_buf[0];
									sda_clk <= 1;
								 end
						8'd17  : sda_clk <= 0;		 
						
						8'd18  : begin						
									sda <= data_buf[1];
									sda_clk <= 1;
								end
						8'd19  : sda_clk <= 0;
						
						8'd20  :begin						
									sda <= data_buf[2];
									sda_clk <= 1;
								 end
						8'd21  : sda_clk <= 0;
						
						8'd22  : begin						
									sda <= data_buf[3];
									sda_clk <= 1;
								end
								
						8'd23  : sda_clk <= 0;
						8'd24  : begin						
									sda <= data_buf[4];
									sda_clk <= 1;
								 end
								 
						8'd25  : sda_clk <= 0;
						8'd26  : begin						
									sda <= data_buf[5];
									sda_clk <= 1;
								 end
								 
						8'd27  : sda_clk <= 0;
						8'd28  : begin						
									sda <= data_buf[6];
									sda_clk <= 1;
								 end
						8'd29  : sda_clk <= 0;
						
						8'd30  : begin						
									sda <= data_buf[7];
									sda_clk <= 1;
								 end
								 
						8'd31  : begin						
									sda_clk <= 0;
									out_state <= IDLE;
								 end
								 
					endcase
					
			end 
			
		endcase
	
	end

end

endmodule
