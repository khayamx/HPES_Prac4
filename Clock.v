`timescale 1ns / 1ps

module WallClock(
    input CLK100MHZ,    
    input BTNreset,
    input BTNmin,
    input BTNhour,
    output [3:0]SegmentDrivers,
    output [7:0]SevenSegment,
    output reg [5:0]LED
    
//    output reg [3:0]hours1,
//    output reg [3:0]hours2,
//    output reg [3:0]mins1,
//    output reg [3:0]mins2
);

    //Add the reset
    wire Reset;
    Delay_Reset DReset(CLK100MHZ, BTNreset, Reset);
    
    //other buttons
    wire MButton;
    wire HButton;
	
//	Instantiate Debounce modules here
	Debounce DH(CLK100MHZ, BTNhour, HButton);
	Debounce DM(CLK100MHZ, BTNmin, MButton);
	
	
    // registers for storing the time
     reg [3:0] hours1=4'd3;
     reg [3:0] hours2=4'd0;
     reg [3:0] mins1=4'd0;
     reg [3:0] mins2=4'd4;
    
    //Initialize seven segment
    SS_Driver SS_Driver1(CLK100MHZ, Reset, hours2, hours1, mins2, mins1, SegmentDrivers, SevenSegment);
    
    //other registers
    parameter speed = 100000;
    reg [5:0] sec = 6'd55;
    reg [29:0] count = 30'd0;
   
    
    always@(posedge CLK100MHZ) begin
        
        if(MButton)
        begin
        
          if (mins1==4'd9) begin
            mins1<=4'd0;
            if(mins2==4'd5)
             mins2<=4'd0;
             else
             mins2<=mins2+1'd1;
          end
          else 
              mins1 <= mins1+4'd1;  
        end
        
        
        //increment hours 
        if(HButton)
        begin

            if (hours1==4'd9)begin
                hours1<=0;
                hours2 <= hours2+4'd1;end
            else if (hours2==4'd2 && hours1==4'd3)begin
              hours1<=4'd0;
              hours2 <=4'd0;
            end
            else
                hours1<=hours1+4'd1;

        end
        
        
        count <= count + 1'b1;
		
		if (count ==speed)
		begin
		  count <=0;
		  sec <= sec +1'b1;
		  LED <= sec;
	    end	
	    if(sec == 60)
	    begin
	       mins1 <= mins1 +1'b1;
	       sec <=0;
	       LED <= sec;
	           if (mins1== 4'd9)
	           begin
	               mins2<=mins2 + 1'b1;
	               mins1<=0;
	               
	               if (mins2==4'd5)
	               begin
	                   mins2<=0;
	                   //increments hours
	                   if ((hours1==4'd3)&& (hours2==4'd2)) begin //midnight
	                     hours1<=0;
	                     hours2<=0; end
	                   else
	                    hours1=hours1+1'b1;
	                 
	                     if  (hours1==4'd9)
	                     begin
	                        hours2<=hours2+1'b1;
	                        hours1<=0;
	                       
	                       
	                   end
	               end
	           end
	   end
        
        

        
        
    end
  
endmodule

