`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: seg7
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seg7(
    input clk_100MHz,               
    input [7:0] temp_data,          
    output reg [6:0] SEG,           
    output reg [3:0] NAN = 4'hF,    
    output reg [3:0] AN             
    );
    
    
    wire [3:0] tens, ones;
    assign tens = temp_data / 10;           
    assign ones = temp_data % 10;          
    
    
    parameter ZERO  = 7'b000_0001;  // 0
    parameter ONE   = 7'b100_1111;  // 1
    parameter TWO   = 7'b001_0010;  // 2 
    parameter THREE = 7'b000_0110;  // 3
    parameter FOUR  = 7'b100_1100;  // 4
    parameter FIVE  = 7'b010_0100;  // 5
    parameter SIX   = 7'b010_0000;  // 6
    parameter SEVEN = 7'b000_1111;  // 7
    parameter EIGHT = 7'b000_0000;  // 8
    parameter NINE  = 7'b000_0100;  // 9
    parameter DEG   = 7'b001_1100;  // degrees symbol
    parameter C     = 7'b011_0001;  // C
    
    
    reg [1:0] anode_select;         
    reg [16:0] anode_timer;         
    
    
    always @(posedge clk_100MHz) begin 
        if(anode_timer == 99_999) begin         
            anode_timer <= 0;                   
            anode_select <=  anode_select + 1;
        end
        else
            anode_timer <=  anode_timer + 1;
    end
    
    always @(anode_select) begin
        case(anode_select) 
            2'b00 : AN = 4'b1110;   // Turn on ones digit
            2'b01 : AN = 4'b1101;   // Turn on tens digit
            2'b10 : AN = 4'b1011;   // Turn on hundreds digit
            2'b11 : AN = 4'b0111;   // Turn on thousands digit
        endcase
    end
    
    always @*
        case(anode_select)
            2'b00 : SEG = C;    // Set to C for Celsuis
                        
            2'b01 : SEG = DEG;  // Set to degrees symbol
                    
            2'b10 : begin       // TEMPERATURE ONES DIGIT
                        case(ones)
                            4'b0000 : SEG = ZERO;
                            4'b0001 : SEG = ONE;
                            4'b0010 : SEG = TWO;
                            4'b0011 : SEG = THREE;
                            4'b0100 : SEG = FOUR;
                            4'b0101 : SEG = FIVE;
                            4'b0110 : SEG = SIX;
                            4'b0111 : SEG = SEVEN;
                            4'b1000 : SEG = EIGHT;
                            4'b1001 : SEG = NINE;
                        endcase
                    end
                    
            2'b11 : begin       // TEMPERATURE TENS DIGIT
                        case(tens)
                            4'b0000 : SEG = ZERO;
                            4'b0001 : SEG = ONE;
                            4'b0010 : SEG = TWO;
                            4'b0011 : SEG = THREE;
                            4'b0100 : SEG = FOUR;
                            4'b0101 : SEG = FIVE;
                            4'b0110 : SEG = SIX;
                            4'b0111 : SEG = SEVEN;
                            4'b1000 : SEG = EIGHT;
                            4'b1001 : SEG = NINE;
                        endcase
                    end
        endcase
    
endmodule
