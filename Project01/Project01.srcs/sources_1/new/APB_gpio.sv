`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: APB_gpio
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

`define LED_OFF 7'h04
`define SW_OFF 7'h00

module APB_gpio #(
    // Configurable Parameters
    parameter DW = 32 ,  // Data width
    parameter AW = 32  ,  // Address width
    // Derived Parameters
    localparam CW = 1 + DW + AW ,  // Command width  {pWRITE, pWDATA, pADDR}  
    localparam RW =  DW              // Response width { pRDATA}
)(
    input logic pCLK,
    input logic pRESETn,

    // APB signals
    input logic [AW-1:0] pADDR,
    input logic  pSEL, // for each peripheral
    input logic  pENABLE,
    input logic  pWRITE,
    input logic [DW-1:0] pWDATA,
    output logic [DW-1:0] pRDATA,
    output logic  pREADY,
    output logic  pSLVERR,

    // to fpga pins
    input logic [15:0] switch,
    output logic [15:0] led
);

    // define register for GPO device 
    logic [15:0] buf_gpo;
    logic wr_en;

    // decoding logic 
    assign wr_en = pSEL & pWRITE & pREADY & pENABLE ; 
                               

    // write data into register when selected 
    always_ff @( posedge pCLK ) begin : write_logic
        if (!pRESETn) begin
            buf_gpo <= 0;
        end else begin
            if (wr_en) begin
                if(pADDR[6:0] == `LED_OFF) begin
                    buf_gpo <= pWDATA[15:0];
                end
            end
        end
    end

    assign led = buf_gpo;


    // Reading data from switches

    // define register
    logic [31:0] buf_in;
    logic rd_en;
    assign rd_en = pSEL & !pWRITE & pREADY & pENABLE ; 

    // connect to outside 
    always_comb begin
        if (rd_en && pADDR[6:0] == `SW_OFF) begin
            pRDATA = {16'b0, switch}; // Concatenate 16'b0 with switch
        end else begin
            pRDATA = 32'b0; // Default value
        end
    end

    // Ready state logic
    assign pREADY = 1;


    
    // APB Slave Error Response
    // write fail, occurs when we write to an invalid address
    logic write_fail;
    assign write_fail = (wr_en && pADDR[6:0] != `LED_OFF) ? 1'b1 : 1'b0;

    // read fail, occurs when we read an invalid address
    logic read_fail;
    assign read_fail = (rd_en && pADDR[6:0] != `SW_OFF) ? 1'b1 : 1'b0;
    
    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            pSLVERR <= 1'b0;
        end else begin
            pSLVERR <= write_fail | read_fail;
        end
    end

endmodule
