`timescale 1ns / 1ps
module spi_slave(
  input sclk,MOSI,cs,
  output[11:0] dout,
  output reg done
);
  typedef enum bit {detect_start = 1'b0, read_data=1'b1} state_type;
  state_type state=detect_start;
  
  reg[11:0] temp=12'h000;
  int count =0;
  always @(posedge sclk)
    begin
      case(state)
        detect_start: 
          begin
            done<=1'b0;
            if(cs==1'b0)
              state<=read_data;
            else 
              state<= detect_start;
          end
    read_data: begin
      if(count<=11)
        begin
          count<=count+1;
          temp<={MOSI,temp[11:1]};
        end
      else
        begin
          count<=0;
          done<=1'b1;
          state<=detect_start;
          
        end
    end
       // default : state<=detect_start;
      endcase
        end
  assign dout = temp;
        
endmodule