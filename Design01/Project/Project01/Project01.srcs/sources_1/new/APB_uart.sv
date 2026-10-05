`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitar Trajkovski
// 
// Create Date: 
// Design Name: 
// Module Name: APB_uart
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

`define UART_CONF_OFF 7'h00
`define UART_SPEED_OFF 7'h04
`define UART_TX_OFF 7'h08

module APB_uart #(
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
    output logic tx
);


    // custom logic
    logic rx_empty;
    logic [7:0] data_out;
    
    interface_circuit interface_circuit_inst (
        .clock(pCLK),
        .reset(!pRESETn),
        .r_input(data_reg),
        .write_req(wr_bus_en[2]),
        .read_req(tx_done),
        .rx_empty(rx_empty),
        .r_out(data_out)
    );
    
    logic tx_done;
    logic start_uart;

    assign start_uart = tx_start_reg & ~rx_empty;

    transmitter_system transmitter_system_inst (
        .clock(pCLK),
        .reset(!pRESETn),
        .tx_start(start_uart),
        .limit(limit_reg),
        .data_in(data_out),
        .tx(tx),
        .tx_done(tx_done)
    );


    logic wr_en;
    assign wr_en = pSEL & pWRITE  & pENABLE & pREADY;

    logic [2:0] wr_bus_en;
    assign wr_bus_en[0] = wr_en & (pADDR[6:0] == `UART_CONF_OFF); // write to the first register
    assign wr_bus_en[1] = wr_en & (pADDR[6:0] == `UART_SPEED_OFF); // write to the first register
    assign wr_bus_en[2] = wr_en & (pADDR[6:0] == `UART_TX_OFF); // write to the first register 


    // write interface


    // reg data 0x0
    logic tx_start_reg;
    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            tx_start_reg <= 0;
        end else begin
            if (wr_bus_en[0]) begin
                tx_start_reg <= pWDATA[0];
            end
        end
    end

    // reg data 0x4
    logic [15:0] limit_reg;
    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            limit_reg <= 0;
        end else begin
            if (wr_bus_en[1]) begin
                limit_reg <= pWDATA[15:0];
            end
        end
    end

    // reg data 0x8  
    logic [7:0] data_reg;
    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            data_reg <= 0;
        end else begin
            if (wr_bus_en[2]) begin
                data_reg <= pWDATA[7:0];
            end
        end
    end

    // Ready logic generation
    always_comb begin
        case (pADDR[6:0])
            `UART_TX_OFF: begin
                pREADY = rx_empty; 
            end
            default: begin
                pREADY = 1'b1;
            end
        endcase
    end
    
    
    assign pRDATA = 0;

    // APB Slave Error Response
    // write fail, occurs when we write to an invalid address
    logic write_fail;
    assign write_fail = (wr_en && pADDR[6:0] != `UART_CONF_OFF && pADDR[6:0] != `UART_SPEED_OFF && pADDR[6:0] != `UART_TX_OFF) ? 1'b1 : 1'b0;

    // read fail, occurs when we read an invalid address
    logic read_fail;
    assign read_fail = 1'b0;
    
    always_ff @(posedge pCLK) begin
        if (!pRESETn) begin
            pSLVERR <= 1'b0;
        end else begin
            pSLVERR <= write_fail | read_fail;
        end
    end

endmodule


module baud_rate_generator // General Purpose counter        
    #(parameter PRESCALER_WIDTH = 4)
    (
        input logic clock,
        input logic reset,
        input logic [PRESCALER_WIDTH-1:0] limit,
        output logic baud_rate_tick
    );

    logic [PRESCALER_WIDTH-1:0] count;

    // when the counter reaches the limit, the sample_tick signal is generated

    always_ff @(posedge clock) begin
        if(reset) begin
            count <= 0;
        end else begin
            if(count == limit-1) begin
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end

    assign baud_rate_tick = (count == limit-1);
endmodule

module uart_fsm #(
    parameter DATA_WIDTH = 8
    ) 
(
    input logic clock,
    input logic reset,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic baud_rate_tick,
    input logic tx_start,
    output logic tx,
    output logic tx_done,
    output logic baud_rst // used for baud rate generator reset
);

    // define the states
    typedef enum logic [1:0] { // binary encoding
        IDLE,
        START,
        DATA,
        STOP
    } state_uart_t;
    
 
    state_uart_t state, next_state;

    // signal declarations 
    logic [DATA_WIDTH-1:0] b_reg, b_reg_next;
    logic [3:0] n_counter, n_counter_next; // counter for number of symbols 
    logic tx_done_next, tx_reg, tx_reg_next;


    // state register
    always_ff @(posedge clock) begin
        if (reset) begin
            state <= IDLE;
            b_reg <= 0;
            n_counter <= 0;
            tx_done <= 0;
            tx_reg <= 1; // idle state state of the tx line
        end
        else begin
            state <= next_state;
            b_reg <= b_reg_next;
            n_counter <= n_counter_next;
            tx_done <= tx_done_next;
            tx_reg <= tx_reg_next;
        end
    end

    // state transition logic
    always_comb begin
        next_state = state;
        b_reg_next = b_reg;
        n_counter_next = n_counter;
        tx_done_next = 0;
        tx_reg_next = tx_reg;
        baud_rst = 1'b0;

        case (state)
            IDLE : begin
                tx_reg_next = 1'b1;
                if(tx_start) begin
                    next_state = START;
                    b_reg_next = data_in;
                    baud_rst = 1'b1;
                end
            end 
            START : begin
                tx_reg_next = 1'b0;
                if (baud_rate_tick) begin
                    next_state = DATA;
                    n_counter_next = 0;
                end
            end
            DATA : begin
                tx_reg_next = b_reg[0];
                if (baud_rate_tick) begin
                    if (n_counter == DATA_WIDTH-1) begin
                        next_state = STOP;
                    end
                    else begin
                        n_counter_next = n_counter + 1;
                        b_reg_next = {1'b0, b_reg[7:1]};
                    end
                end
            end
            STOP : begin
                tx_reg_next = 1'b1;
                if (baud_rate_tick) begin
                    begin
                        next_state = IDLE;
                        tx_done_next = 1'b1;
                    end
                end
            end
        endcase
    end

    assign tx = tx_reg;
endmodule

module transmitter_system(
    input logic clock,
    input logic reset,
    input logic [15:0] limit, 
    input logic tx_start,
    input logic [7:0] data_in,
    output logic tx,
    output logic tx_done
);

    logic baud_rate_tick;
    logic baud_rst;
    logic local_reset;

    
    assign local_reset = reset | baud_rst;

    baud_rate_generator #(
        .PRESCALER_WIDTH(16)
    ) baud_rate_generator_inst (
        .clock(clock),
        .reset(local_reset),
        .limit(limit),
        .baud_rate_tick(baud_rate_tick)
    );

    uart_fsm #(
        .DATA_WIDTH(8)
    ) uart_fsm_inst (
        .clock(clock),
        .reset(reset),
        .data_in(data_in),
        .baud_rate_tick(baud_rate_tick),
        .tx_start(tx_start),
        .tx(tx),
        .tx_done(tx_done),
        .baud_rst(baud_rst)
    );


endmodule


module interface_circuit #(
    parameter DATA_WIDTH = 8
) (
    input logic clock, 
    input logic reset,
    input logic [DATA_WIDTH-1:0] r_input, 
    input logic write_req, // receiving done  
    input logic read_req, // read uart request 
    output logic rx_empty,
    output logic [DATA_WIDTH-1:0] r_out
);
    
    // one word buffer 
    always_ff @(posedge clock) begin : OneWordBuffer
        if (reset) begin
            r_out <= 0;
        end else begin
            if (write_req) begin
                r_out <= r_input;
            end
        end
    end

    // rx_empty signal generation 
    logic set_flag, clr_flag, flag;

    assign set_flag = write_req;
    assign clr_flag = read_req;

    always_ff @( posedge clock ) begin : rx_empty_gen
         if (reset) begin
            flag <= 0; // on reset buffer is empty 
        end else begin
            if (set_flag) begin
                flag <= 1;
            end else begin
                if (clr_flag) begin
                    flag <= 0;
                end
            end
        end
    end

    assign rx_empty = ~flag;

endmodule 







