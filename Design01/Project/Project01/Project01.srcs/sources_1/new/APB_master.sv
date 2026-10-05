`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: APB_master
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

module APB_master #(
    // Configurable Parameters
    parameter DW = 32 ,  // Data width
    parameter AW = 32  ,  // Address width
    // Derived Parameters
    localparam CW = 1 + DW + AW ,  // Command width  {pWRITE, pWDATA, pADDR}  
    localparam RW = 1 + DW              // Response width { pSLVERR, pRDATA}
)(
    input logic pCLK,
    input logic pRESETn,
    // Command & Response Interface
    input  logic [CW-1:0] i_cmd   ,  // Command.-
    input  logic          i_valid ,  // Denotes transfer 
    output logic [RW-1:0] o_resp  ,  // Response
    output logic          o_ready ,  // Ready
    // APB signals
    output logic [AW-1:0] pADDR,
    output logic  pSELx, // for each peripheral
    output logic  pENABLE,
    output logic  pWRITE,
    output logic [DW-1:0] pWDATA,
    input logic [DW-1:0] pRDATA,
    input logic  pREADY,
    input logic  pSLVERR
);

    
    
    // APB Master FSM
    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } state_apb;

    state_apb state, next_state;
    logic delay_write;
    // State register
    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (i_valid) begin
                    next_state = SETUP;
                end
            end
            SETUP: begin
                next_state = ACCESS;
            end
            ACCESS: begin
                if (pREADY && i_valid) begin
                    next_state = SETUP;
                end else if (pREADY && !i_valid) begin
                    next_state = IDLE;
                end
            end
            default: next_state = state;
        endcase
    end

    // Output signals of AHB

    // APB signals that are independent of the current state
    assign pADDR = i_cmd[AW-1:0];
    assign pWDATA = i_cmd[CW-2:AW];
    assign pWRITE = i_cmd[CW-1];

    // APB signals that depend on the current state
    assign pENABLE = (state == ACCESS) ? 1 : 0;
    assign pSELx = (state == SETUP  || state == ACCESS) ? 1 : 0;
    // To command interface
    assign o_ready = pENABLE && pREADY; // to signal that we sucessfully read the data. Figure 3.4 T2 cycle or Figure 3.5 T4 cycle
    assign o_resp = {pSLVERR, pRDATA}; // Forward the  slave error and read data. Read data is always valid when pREADY is high.

endmodule

