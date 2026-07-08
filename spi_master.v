module spi_master (
    input  clk,
    input  rst,
    input  start,
    input  [7:0] mosi_data,
    output reg sclk,
    output reg cs_n,
    output reg mosi,
    input      miso,
    output reg [7:0] miso_data,
    output reg done
);

parameter CLKDIV = 10; // 100MHz / 10 = 10MHz toggle = 5MHz SPI clock

// Internal registers
reg [3:0]  clk_count = 0;
reg [3:0]  bit_count  = 0;
reg [7:0]  tx_shift   = 0;
reg [7:0]  rx_shift   = 0;

// FSM States
localparam IDLE     = 2'd0;
localparam TRANSFER = 2'd1;
localparam FINISH   = 2'd2;

reg [1:0] state = IDLE;

// Tracks previous sclk value to detect edges
reg sclk_prev = 0;

// --- Main FSM ---
always @(posedge clk) begin
    if (rst) begin
        state     <= IDLE;
        sclk      <= 0;
        cs_n      <= 1;
        mosi      <= 0;
        done      <= 0;
        clk_count <= 0;
        bit_count <= 0;
        tx_shift  <= 0;
        rx_shift  <= 0;
        miso_data <= 0;
        sclk_prev <= 0;
    end else begin
        done      <= 0;
        sclk_prev <= sclk;

        case (state)

            // ----- IDLE -----
            // Wait for start pulse
            IDLE: begin
                cs_n      <= 1;
                sclk      <= 0;
                clk_count <= 0;
                bit_count <= 0;
                mosi      <= 0;

                if (start) begin
                    tx_shift <= mosi_data;
                    cs_n     <= 0;          // Assert chip select
                    mosi     <= mosi_data[7]; // Put MSB on line first
                    state    <= TRANSFER;
                end
            end

            // ----- TRANSFER -----
            // Generate SCLK and shift bits in/out
            TRANSFER: begin
                // Clock divider: toggle sclk every CLKDIV cycles
                if (clk_count == CLKDIV - 1) begin
                    clk_count <= 0;
                    sclk      <= ~sclk;
                end else begin
                    clk_count <= clk_count + 1;
                end

                // Rising edge of sclk detected: sample MISO
                if (sclk && !sclk_prev) begin
                    rx_shift <= {rx_shift[6:0], miso};
                end

                // Falling edge of sclk detected: shift out next MOSI bit
                if (!sclk && sclk_prev) begin
                    tx_shift  <= tx_shift << 1;
                    mosi      <= tx_shift[6]; // Next bit
                    bit_count <= bit_count + 1;

                    if (bit_count == 7) begin
                        state <= FINISH;
                    end
                end
            end

            // ----- FINISH -----
            // Latch received data, deassert CS
            FINISH: begin
                // Wait for sclk to go low before ending
                if (clk_count == CLKDIV - 1) begin
                    clk_count <= 0;
                    sclk      <= 0;
                    cs_n      <= 1;
                    miso_data <= rx_shift;
                    done      <= 1;
                    state     <= IDLE;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

        endcase
    end
end

endmodule