`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2026 10:19:15 PM
// Design Name: 
// Module Name: i2c_master
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


`timescale 1ns / 1ps

module i2c_master #(
    parameter CLK_DIV = 100
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       read_write, // 0 = write, 1 = read
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       done,
    output logic       busy,

    output logic       i2c_scl,
    inout  logic       i2c_sda
);

    typedef enum logic [2:0] {
        IDLE,
        START_COND,
        SEND_BYTE,
        RECV_BYTE,
        STOP_COND
    } state_t;

    state_t state;

    logic [$clog2(CLK_DIV)-1:0] clk_cnt;
    logic [2:0] bit_cnt;

    logic [7:0] shreg_tx;
    logic [7:0] shreg_rx;

    logic sda_out;
    logic sda_oe;

    assign i2c_sda = sda_oe ? sda_out : 1'bz;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            clk_cnt  <= 0;
            bit_cnt  <= 0;
            shreg_tx <= 0;
            shreg_rx <= 0;
            done     <= 0;
            busy     <= 0;
            sda_out  <= 1;
            sda_oe   <= 0;
            i2c_scl  <= 1;
        end else begin
            done <= 0;
            case (state)
                IDLE: begin
                    sda_out <= 1;
                    sda_oe  <= 0;
                    i2c_scl <= 1;
                    busy <= 0;
                    if (start) begin
                        shreg_tx <= tx_data;
                        bit_cnt  <= 7;
                        clk_cnt  <= 0;
                        state    <= START_COND;
                        busy     <= 1;
                    end
                end

                START_COND: begin
                    // pull SDA low while SCL high
                    sda_out <= 0;
                    sda_oe  <= 1;
                    i2c_scl <= 1;
                    state <= SEND_BYTE;
                end

                SEND_BYTE: begin
                    // simple byte send
                    i2c_scl <= 0;
                    sda_out <= shreg_tx[bit_cnt];
                    sda_oe  <= 1;
                    if (clk_cnt == CLK_DIV-1) begin
                        clk_cnt <= 0;
                        i2c_scl <= 1; // raise SCL to sample
                        if (bit_cnt == 0) state <= STOP_COND;
                        else bit_cnt <= bit_cnt - 1;
                    end else clk_cnt <= clk_cnt + 1;
                end

                STOP_COND: begin
                    i2c_scl <= 1;
                    sda_out <= 0;
                    sda_oe  <= 1;
                    state <= IDLE;
                    done <= 1;
                end

            endcase
        end
    end

    assign rx_data = shreg_rx;
    assign busy    = (state != IDLE);

endmodule

