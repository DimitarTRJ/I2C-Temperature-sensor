`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: APB_timer
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


`define COUNT_HIGH 7'h08
`define COUNT_LOW 7'h04
`define CONF 7'h00 // Configuration Register, config[0]: enable, config[1]: clear

module APB_timer #(
    // Configurable Parameters
    parameter DW = 32 ,  // Data width
    parameter AW = 32   // Address width
) (
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
    output logic  pSLVERR
    // External signals
    // no external signals to output
);

    // registers for switches and leds

    logic [63:0] count_reg;
    logic [31:0] config_reg;

    
    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            count_reg <= 64'b0;
        end else begin
            if(config_reg[0]) begin
                if(config_reg[1]) begin
                    count_reg <= 0;
                end else begin
                    count_reg <= count_reg + 1;
                end
            end
        end
    end

    // define register for config device to enable/clear timer
    logic wr_en;
    // decoding logic 
    assign wr_en = pSEL & pWRITE & pREADY & pENABLE ; 
                               
    // write data into config register when selected 
    always_ff @( posedge pCLK ) begin : write_logic
        if (!pRESETn) begin
            config_reg <= 0;
        end else begin
            if (wr_en) begin
                if(pADDR[6:0] == `CONF) begin
                    config_reg <= pWDATA;
                end
            end
        end
    end

    // Reading data counters

    // define register
    logic [31:0] read_data;
    logic rd_en;

    assign rd_en = pSEL & !pWRITE & pREADY & pENABLE ; 
    always_comb begin
        if (rd_en) begin
            case (pADDR[6:0])
                `COUNT_LOW: begin
                    pRDATA = count_reg[31:0];
                end
                `COUNT_HIGH: begin
                    pRDATA = count_reg[63:32];
                end
                default: begin
                    pRDATA = 32'b0;
                end
            endcase
        end else begin
            pRDATA = 32'b0;
        end
    end


    //assign pRDATA = read_data;

    // Ready state logic
    assign pREADY = 1'b1;



    
    // APB Slave Error Response
    // write fail, occurs when we write to an invalid address
    logic write_fail;
    assign write_fail = (wr_en && pADDR[6:0] != `CONF) ? 1'b1 : 1'b0;

    // read fail, occurs when we read an invalid address
    logic read_fail;
    assign read_fail = (rd_en && pADDR[6:0] != `COUNT_LOW && pADDR[6:0] != `COUNT_HIGH) ? 1'b1 : 1'b0;

    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            pSLVERR <= 1'b0;
        end else begin
            pSLVERR <= write_fail | read_fail;
        end
    end

endmodule
