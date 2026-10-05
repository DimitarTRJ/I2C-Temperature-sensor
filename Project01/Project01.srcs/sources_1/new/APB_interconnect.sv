`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: APB_interconnect
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



module APB_interconnect #(
    // Configurable Parameters
    parameter DW = 32 ,  // Data width
    parameter AW = 32  ,  // Address width
    parameter NUM_PERIPHERALS = 64,
    parameter NUM_REG_PERIPHERAL = 32
)(
    // APB signals from master 
    // Notation: Mp<SignalName> - generated from/to master
    input logic [AW-1:0] MpADDR,
    input logic  MpSELx, // for each peripheral
    input logic  MpENABLE,
    input logic  MpWRITE,
    input logic [DW-1:0] MpWDATA,
    output logic [DW-1:0] MpRDATA,
    output logic  MpREADY,
    output logic  MpSLVERR,
    // Notation: Sp<SignalName> - generated from/to slave
    output logic [AW-1:0] SpADDR [NUM_PERIPHERALS-1:0], // array of addresses for each peripheral
    output logic  [NUM_PERIPHERALS-1:0] SpSEL ,
    output logic  [NUM_PERIPHERALS-1:0] SpENABLE ,
    output logic  [NUM_PERIPHERALS-1:0] SpWRITE ,
    output logic [DW-1:0] SpWDATA [NUM_PERIPHERALS-1:0],
    input logic [DW-1:0] SpRDATA [NUM_PERIPHERALS-1:0],
    input logic [NUM_PERIPHERALS-1:0] SpREADY ,
    input logic [NUM_PERIPHERALS-1:0] SpSLVERR
);

    // Addressing 
    // Extracting base address from MpADDR
    
    // the bits for addressing are: (log2(NUM_PERIPHERALS) + log2(NUM_REG_PERIPHERAL) + 2 -1): log2(NUM_REG_PERIPHERAL) + 2
    // log2(NUM_PERIPHERALS) is number of bits to address each slave - base address 
    // log2(NUM_REG_PERIPHERAL) + 2 bits are needed to address every byte in the address space of each peripheral device - offset
    // +2 goes because every register is 32-bit or 4 bytes 

    localparam baseAddr_MSB = ($clog2(NUM_PERIPHERALS) + $clog2(NUM_REG_PERIPHERAL) + 2) - 1; // evalutesto 6+5+2-1=12 for 64 peripherals with 32 registers each
    localparam baseAddr_LSB = $clog2(NUM_REG_PERIPHERAL) + 2; // evaluates to 5+2=7 for 32 registers per peripheral
    
    localparam MSB = $clog2(NUM_PERIPHERALS);
    logic [MSB - 1 : 0] baseAddr;

    assign baseAddr = MpADDR[baseAddr_MSB : baseAddr_LSB];
    
    
    // forwarding signals: MpADDR, MpENABLE, MpWRITE, MpWDATA
    genvar i;
    for (i = 0; i < NUM_PERIPHERALS; i++) begin : gen_addr
        assign SpADDR[i] = MpADDR;
        assign SpENABLE[i] = MpENABLE;
        assign SpWRITE[i] = MpWRITE;
        assign SpWDATA[i] = MpWDATA;
    end

    // Generate SpSEL signal 
    // Decoder: Generate SpSEL signal (one-hot encoding)
    assign SpSEL = MpSELx ? (1 << baseAddr) : 0;

    // MUX for the signals: MpRDATA, MpREADY, MpSLVERR
    always_comb begin : readData
        MpREADY = SpREADY[baseAddr]; // modeling MUX with array indexing, so called dynamic indexing
        MpSLVERR = SpSLVERR[baseAddr];
        // Read data
        MpRDATA = 0;
        if (!MpWRITE & MpSELx) begin
            MpRDATA = SpRDATA[baseAddr];
        end
    end

endmodule
