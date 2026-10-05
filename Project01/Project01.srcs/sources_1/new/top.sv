`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: top
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

module top (
    // Clock and Reset
    input logic clock,
    input logic resetn, 
    // leds and switches
    output logic [15:0] leds,
    input logic [15:0] switches,
    output logic tx,
    
    // I2C pins
    output logic i2c_scl,
    inout logic i2c_sda
);



// Parameters
localparam AW = 32;
localparam DW = 32;
localparam NUM_PERIPHERALS = 64;
localparam NUM_REG_PERIPHERAL = 32;
// Derived Parameters
localparam CW = 1 + DW + AW;
localparam RW = 1 + DW;

// IO bus signals
logic [31:0] io_address;
logic io_addr_strobe;
logic [31:0] io_write_data;
logic io_write_strobe;
logic [3:0] io_byte_enable;
logic [31:0] io_read_data;
logic io_read_strobe;
logic io_ready;


logic reset;

assign reset = ~resetn;

microblaze_mcs_0 your_instance_name (
  .Clk(clock),                          // input wire Clk
  .Reset(reset),                      // input wire Reset
  .IO_addr_strobe(io_addr_strobe),    // output wire io_addr_strobe
  .IO_address(io_address),            // output wire [31 : 0] IO_address
  .IO_byte_enable(io_byte_enable),    // output wire [3 : 0] IO_byte_enable
  .IO_read_data(io_read_data),        // input wire [31 : 0] IO_read_data
  .IO_read_strobe(io_read_strobe),    // output wire IO_read_strobe
  .IO_ready(io_ready),                // input wire IO_ready
  .IO_write_data(io_write_data),      // output wire [31 : 0] IO_write_data
  .IO_write_strobe(io_write_strobe)  // output wire IO_write_strobe
);

// APB master 
logic [AW-1:0] MpADDR;
logic [DW-1:0] MpWDATA;
logic MpSELx;
logic MpWRITE;
logic MpREADY;
logic MpENABLE;
logic MpSLVERR;
logic [DW-1:0] MpRDATA;

// instantiate APB_Bridge
APB_Bridge #(
    .DW(DW),
    .AW(AW),
    .BRG_BASE(32'hC0000000)
) apb_bridge_inst (
    .CLK(clock),
    .RESETn(resetn),
    // io_bus
    .io_address(io_address),
    .io_addr_strobe(io_addr_strobe),
    .io_write_data(io_write_data),
    .io_write_strobe(io_write_strobe),
    .io_byte_enable(io_byte_enable),
    .io_read_data(io_read_data),
    .io_read_strobe(io_read_strobe),
    .io_ready(io_ready),
    // apb_signals
    .pADDR   (MpADDR),
    .pSELx   (MpSELx),
    .pENABLE (MpENABLE),
    .pWRITE  (MpWRITE),
    .pWDATA  (MpWDATA),
    .pRDATA  (MpRDATA),
    .pREADY  (MpREADY),
    .pSLVERR (MpSLVERR)
);

// instantiate a interconnect 
logic [AW-1:0] SpADDR [NUM_PERIPHERALS-1:0]; // array of addresses for each peripheral
logic [NUM_PERIPHERALS-1:0] SpSEL;
logic [NUM_PERIPHERALS-1:0] SpENABLE;
logic [NUM_PERIPHERALS-1:0] SpWRITE;
logic [DW-1:0] SpWDATA [NUM_PERIPHERALS-1:0];
logic [DW-1:0] SpRDATA [NUM_PERIPHERALS-1:0];
logic [NUM_PERIPHERALS-1:0] SpREADY;
logic [NUM_PERIPHERALS-1:0] SpSLVERR;

APB_interconnect #(
    .DW(DW),                  // Data width
    .AW(AW),                  // Address width
    .NUM_PERIPHERALS(64),     // Number of peripherals
    .NUM_REG_PERIPHERAL(32)   // Number of registers per peripheral
) u_apb_interconnect (
    .MpADDR    (MpADDR),
    .MpSELx    (MpSELx),
    .MpENABLE  (MpENABLE),
    .MpWRITE   (MpWRITE),
    .MpWDATA   (MpWDATA),
    .MpRDATA   (MpRDATA),
    .MpREADY   (MpREADY),
    .MpSLVERR  (MpSLVERR),
    .SpADDR    (SpADDR),
    .SpSEL     (SpSEL),
    .SpENABLE  (SpENABLE),
    .SpWRITE   (SpWRITE),
    .SpWDATA   (SpWDATA),
    .SpRDATA   (SpRDATA),
    .SpREADY   (SpREADY),
    .SpSLVERR  (SpSLVERR)
);


// instantiate a gpio device.
// the base address will be 0 

APB_gpio #(
    .DW(DW),   // Data width
    .AW(AW)    // Address width
) u_apb_gpio (
    .pCLK    (clock),
    .pRESETn (resetn),
    .pADDR   (SpADDR[0]),
    .pSEL    (SpSEL[0]),
    .pENABLE (SpENABLE[0]),
    .pWRITE  (SpWRITE[0]),
    .pWDATA  (SpWDATA[0]),
    .pRDATA  (SpRDATA[0]),
    .pREADY  (SpREADY[0]),
    .pSLVERR (SpSLVERR[0]),
    .switch  (switches),
    .led     (leds)
);

APB_timer #(
    .DW(DW),   // Data width
    .AW(AW)    // Address width
) u_apb_timer (
    .pCLK    (clock),
    .pRESETn (resetn),
    .pADDR   (SpADDR[1]),
    .pSEL    (SpSEL[1]),
    .pENABLE (SpENABLE[1]),
    .pWRITE  (SpWRITE[1]),
    .pWDATA  (SpWDATA[1]),
    .pRDATA  (SpRDATA[1]),
    .pREADY  (SpREADY[1]),
    .pSLVERR (SpSLVERR[1])
);

APB_uart #(
    .DW(DW),   // Data width
    .AW(AW)    // Address width
) u_apb_uart (
    .pCLK    (clock),
    .pRESETn (resetn),
    .pADDR   (SpADDR[2]),
    .pSEL    (SpSEL[2]),
    .pENABLE (SpENABLE[2]),
    .pWRITE  (SpWRITE[2]),
    .pWDATA  (SpWDATA[2]),
    .pRDATA  (SpRDATA[2]),
    .pREADY  (SpREADY[2]),
    .pSLVERR (SpSLVERR[2]),
    .tx      (tx)
);

APB_i2c #(
    .DW(DW),
    .AW(AW)
) u_apb_i2c (
    .PCLK    (clock),
    .PRESETn (resetn),

    .PADDR   (SpADDR[3]),
    .PSEL    (SpSEL[3]),
    .PENABLE (SpENABLE[3]),
    .PWRITE  (SpWRITE[3]),
    .PWDATA  (SpWDATA[3]),
    .PRDATA  (SpRDATA[3]),
    .PREADY  (SpREADY[3]),
    .PSLVERR (SpSLVERR[3]),

    .i2c_scl     (i2c_scl),
    .i2c_sda     (i2c_sda)
);


// the "rest" of peripherals
genvar i;
for (i = 4; i < NUM_PERIPHERALS; i++) begin : gen_addr
    assign SpSLVERR[i] = 1; // generate an error signal when addressing unknown peripherals peripheral
    assign SpREADY[i] = 0;
    assign SpRDATA[i] = 32'hFFFFFFFF;
end


endmodule
