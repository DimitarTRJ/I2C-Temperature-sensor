`define I2C_CTRL  7'h00
`define I2C_STAT  7'h04
`define I2C_TEMP  7'h08

module APB_i2c #( 
    parameter DW = 32,
    parameter AW = 32)(
    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic [31:0] PADDR,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,

    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR,

    output logic i2c_scl,
    inout  logic i2c_sda
);

    logic start;
    logic busy;
    logic signed [7:0] temp_msb;

    /* ---------- Write ---------- */
    always_ff @(posedge PCLK) begin
        if (!PRESETn)
            start <= 1'b0;
        else if (PSEL && PENABLE && PWRITE && PADDR[6:0] == `I2C_CTRL)
            start <= PWDATA[0];
        else
            start <= 1'b0;   // auto clear
    end

    /* ---------- Read ---------- */
    always_comb begin
        PRDATA = 32'b0;
        if (PSEL && !PWRITE) begin
            case (PADDR[6:0])
                `I2C_STAT: PRDATA = {31'b0, busy};
                `I2C_TEMP: PRDATA = {{24{temp_msb[7]}}, temp_msb};
                default:   PRDATA = 32'b0;
            endcase
        end
    end

    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;

    /* ---------- I2C master ---------- */
    i2c_master u_i2c (
        .clk       (PCLK),
        .reset     (!PRESETn),
        .start     (start),
        .busy      (busy),
        .SCL       (i2c_scl),
        .SDA       (i2c_sda),
        .temp_msb  (temp_msb)
    );

endmodule

module i2c_master (
    input  logic clk,
    input  logic reset,
    input  logic start,

    output logic busy,
    output logic SCL,
    inout  logic SDA,

    output logic signed [7:0] temp_msb
);

    /* ---------- ADT7420 constants ---------- */
    localparam [7:0] ADDR_WR  = 8'h96;   // 0x4B << 1 | 0
    localparam [7:0] ADDR_RD  = 8'h97;   // 0x4B << 1 | 1
    localparam [7:0] TEMP_REG = 8'h00;

    /* ---------- I2C clock (~10 kHz) ---------- */
    logic [12:0] div;
    always_ff @(posedge clk or posedge reset)
        if (reset) div <= 0;
        else div <= div + 1;

    assign SCL = div[12];

    /* ---------- SDA ---------- */
    logic sda_out, sda_oe;
    assign SDA = sda_oe ? sda_out : 1'bz;

    /* ---------- FSM ---------- */
    typedef enum logic [4:0] {
        IDLE,
        START,
        SEND_ADDR_WR,
        SEND_REG,
        REP_START,
        SEND_ADDR_RD,
        ADDR_ACK,
        RX_MSB,
        ACK_MSB,
        RX_LSB,
        NACK_LSB,
        STOP
    } state_t;

    state_t state;
    logic [2:0] bitt;
    logic [7:0] shift;
    logic [7:0] lsb_dummy;

    always_ff @(posedge SCL or posedge reset) begin
        if (reset) begin
            state    <= IDLE;
            busy     <= 0;
            sda_out  <= 1;
            sda_oe   <= 1;
            bitt      <= 7;
            temp_msb <= 0;
        end else begin
            case (state)

                /* ---------- Idle ---------- */
                IDLE: begin
                    busy    <= 0;
                    sda_out <= 1;
                    sda_oe  <= 1;
                    if (start) begin
                        busy  <= 1;
                        state <= START;
                    end
                end

                /* ---------- START ---------- */
                START: begin
                    sda_out <= 0;
                    shift   <= ADDR_WR;
                    bitt     <= 7;
                    state   <= SEND_ADDR_WR;
                end

                /* ---------- Send address (WRITE) ---------- */
                SEND_ADDR_WR: begin
                    sda_out <= shift[bitt];
                    if (bitt == 0) begin
                        shift <= TEMP_REG;
                        bitt   <= 7;
                        state <= SEND_REG;
                    end else
                        bitt <= bitt - 1;
                end

                /* ---------- Send register pointer ---------- */
                SEND_REG: begin
                    sda_out <= shift[bitt];
                    if (bitt == 0)
                        state <= REP_START;
                    else
                        bitt <= bitt - 1;
                end

                /* ---------- Repeated START ---------- */
                REP_START: begin
                    sda_out <= 1;
                    sda_out <= 0;
                    shift   <= ADDR_RD;
                    bitt     <= 7;
                    state   <= SEND_ADDR_RD;
                end

                /* ---------- Send address (READ) ---------- */
                SEND_ADDR_RD: begin
                    sda_out <= shift[bitt];
                    if (bitt == 0)
                        state <= ADDR_ACK;
                    else
                        bitt <= bitt - 1;
                end

                ADDR_ACK: begin
                    sda_oe <= 0;
                    bitt    <= 7;
                    state  <= RX_MSB;
                end

                /* ---------- Receive MSB ---------- */
                RX_MSB: begin
                    temp_msb[bitt] <= SDA;
                    if (bitt == 0)
                        state <= ACK_MSB;
                    else
                        bitt <= bitt - 1;
                end

                ACK_MSB: begin
                    sda_oe  <= 1;
                    sda_out <= 0;     // ACK
                    bitt     <= 7;
                    state   <= RX_LSB;
                end

                /* ---------- Receive LSB (discard) ---------- */
                RX_LSB: begin
                    sda_oe <= 0;
                    lsb_dummy[bitt] <= SDA;
                    if (bitt == 0)
                        state <= NACK_LSB;
                    else
                        bitt <= bitt - 1;
                end

                NACK_LSB: begin
                    sda_oe  <= 1;
                    sda_out <= 1;     // NACK
                    state   <= STOP;
                end

                /* ---------- STOP ---------- */
                STOP: begin
                    sda_out <= 1;
                    busy    <= 0;
                    state   <= IDLE;
                end

            endcase
        end
    end

endmodule



