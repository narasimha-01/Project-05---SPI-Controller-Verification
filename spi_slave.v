module spi_slave (
    input  clk,
    input  rst,
    input  sclk,
    input  cs_n,
    input  mosi,
    output reg miso,
    input  [7:0] slave_tx_data,   // Data slave wants to send
    output reg [7:0] slave_rx_data, // Data slave received
    output reg rx_done
);

reg sclk_prev  = 0;
reg cs_prev    = 1;
reg [2:0] bit_count = 0;
reg [7:0] tx_shift  = 0;
reg [7:0] rx_shift  = 0;

always @(posedge clk) begin
    if (rst) begin
        sclk_prev    <= 0;
        cs_prev      <= 1;
        bit_count    <= 0;
        tx_shift     <= 0;
        rx_shift     <= 0;
        miso         <= 0;
        slave_rx_data<= 0;
        rx_done      <= 0;
    end else begin
        sclk_prev <= sclk;
        cs_prev   <= cs_n;
        rx_done   <= 0; // Default

        // CS falling edge: load TX data, prepare to send
        if (!cs_n && cs_prev) begin
            tx_shift  <= slave_tx_data;
            bit_count <= 0;
            miso      <= slave_tx_data[7]; // Put MSB first
        end

        // SCLK rising edge: sample MOSI (master is sending)
        if (sclk && !sclk_prev && !cs_n) begin
            rx_shift  <= {rx_shift[6:0], mosi};
            bit_count <= bit_count + 1;

            // After 8 bits received
            if (bit_count == 7) begin
                slave_rx_data <= {rx_shift[6:0], mosi};
                rx_done       <= 1;
            end
        end

        // SCLK falling edge: update MISO with next bit
        if (!sclk && sclk_prev && !cs_n) begin
            tx_shift <= tx_shift << 1;
            miso     <= tx_shift[6];
        end
    end
end

endmodule