`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: APB_bridge
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


module APB_Bridge  #(
    // Configurable Parameters
    parameter DW = 32 ,  // Data width
    parameter AW = 32  ,  // Address width
    parameter BRG_BASE = 32'hc000_0000, // 0xC0FFFFFF
    // Derived Parameters
    localparam CW = 1 + DW + AW ,  // Command width  {pWRITE, pWDATA, pADDR}  
    localparam RW = 1 + DW              // Response width { pSLVERR, pRDATA}
)(
    input logic CLK,
    input logic RESETn,
    // IO bus
    // uBLAZE MCS I/O bus
    input logic [31:0] io_address,
    input logic io_addr_strobe,
    input logic [31:0] io_write_data,
    input logic io_write_strobe,
    input logic [3:0] io_byte_enable,
    output logic [31:0] io_read_data,
    input logic io_read_strobe,
    output logic io_ready,
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
    
    logic [CW-1:0] cmd;
    logic valid;
    logic [RW-1:0] resp;
    logic          ready;
    // The APB subsystem acts as slave on I/O bus. It starting address is 0xC000_0000
    logic mcs_bridge_enable;
    assign mcs_bridge_enable = (io_address[31:24] == BRG_BASE[31:24]);

    // We will use a address_strobe to generate the valid signal. 
    // regardless of read or write, address_strobe is always asserted when there is a valid address
    assign valid = io_addr_strobe & mcs_bridge_enable; // do not generate any request if we did not select our system

    // Command generation
    // write_req is equal to one when io_write_strobe is asserted and io_read_strobe is not asserted
    // We need to delay the write signal until the next command is accepted (i_valid is high)


    logic write_req, write, delay_write;
        
    assign write = io_write_strobe & ~io_read_strobe;
    
    always_ff @(posedge CLK or negedge RESETn) begin
        if (!RESETn) begin
            delay_write <= 0;
        end else begin
            if(valid) begin
                delay_write <= write;
            end
        end
    end

    assign write_req = (valid == 1) ? write : delay_write;

    // Command generation
    assign cmd = {write_req, io_write_data, io_address};

   

    // Read data. If there is an error we will send deadFA17

    always_comb begin
        io_read_data = resp[DW-1:0];
        if (resp[DW]) begin
            io_read_data = 32'hDEADFA17; 
        end
    end

    // Ready signal
    assign io_ready = ready & mcs_bridge_enable;

    // NOTE: we ignore signals io_byte_enable
    // This means we will not use byte enables for the APB transfer. We will send the full 32 bits of data.
    
    
    // Instantiate APB master
    
    APB_master #(
    .DW(DW),   // Data width
    .AW(AW)    // Address width
    ) u_apb_master (
        .pCLK    (CLK),
        .pRESETn (RESETn),
        .i_cmd   (cmd),
        .i_valid (valid),
        .o_resp  (resp),
        .o_ready (ready),
        .pADDR   (pADDR),
        .pSELx   (pSELx),
        .pENABLE (pENABLE),
        .pWRITE  (pWRITE),
        .pWDATA  (pWDATA),
        .pRDATA  (pRDATA),
        .pREADY  (pREADY),
        .pSLVERR (pSLVERR)
    );

endmodule

