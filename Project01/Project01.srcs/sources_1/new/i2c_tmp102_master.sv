`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 09:02:43 PM
// Design Name: 
// Module Name: i2c_tmp102_master
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


module i2c_tmp102_master (
    input  logic clk,
    input  logic resetn,
    input  logic start,
    output logic busy,
    output logic done,
    output logic [15:0] temp,
    output logic scl,
    inout  logic sda
);

    typedef enum logic [2:0] {
        IDLE,
        START,
        READ_MSB,
        READ_LSB,
        STOP
    } state_t;

    state_t state;

    // For now: **DUMMY IMPLEMENTATION**
    // This guarantees UART + APB correctness first

    always_ff @(posedge clk) begin
        if (!resetn) begin
            state <= IDLE;
            busy  <= 0;
            done  <= 0;
            temp  <= 16'h0000;
        end else begin
            done <= 0;
            case (state)
                IDLE: begin
                    busy <= 0;
                    if (start) begin
                        busy <= 1;
                        state <= START;
                    end
                end
                START: begin
                    temp <= 16'd400; // 25.0°C = 400 * 0.0625
                    state <= STOP;
                end
                STOP: begin
                    busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

    assign scl = 1'b1;
    assign sda = 1'bz;

endmodule

