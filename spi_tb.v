`timescale 1ns / 1ps

module spi_tb;

// --- Declare signals ---
reg        clk         = 0;
reg        rst         = 0;
reg        start       = 0;
reg [7:0]  master_send = 8'h00;
reg [7:0]  slave_send  = 8'h00;

wire        sclk;
wire        cs_n;
wire        mosi;
wire        miso;
wire [7:0]  master_received;
wire [7:0]  slave_received;
wire        master_done;
wire        slave_rx_done;

// --- 100MHz clock ---
always #5 clk = ~clk;

// --- Instantiate Master ---
spi_master DUT_MASTER (
    .clk       (clk),
    .rst       (rst),
    .start     (start),
    .mosi_data (master_send),
    .sclk      (sclk),
    .cs_n      (cs_n),
    .mosi      (mosi),
    .miso      (miso),
    .miso_data (master_received),
    .done      (master_done)
);

// --- Instantiate Slave ---
spi_slave DUT_SLAVE (
    .clk          (clk),
    .rst          (rst),
    .sclk         (sclk),
    .cs_n         (cs_n),
    .mosi         (mosi),
    .miso         (miso),
    .slave_tx_data(slave_send),
    .slave_rx_data(slave_received),
    .rx_done      (slave_rx_done)
);

// --- Transfer task ---
// Sets data, pulses start, waits for done, checks results
task do_transfer;
    input [7:0] m_data; // Master sends this to slave
    input [7:0] s_data; // Slave sends this to master
    input [63:0] test_name; // Just for display
    begin
        // Load both sides before transfer
        @(posedge clk); #1;
        master_send = m_data;
        slave_send  = s_data;

        // Wait one clock then pulse start
        @(posedge clk); #1;
        start = 1;
        @(posedge clk); #1;
        start = 0;

        // Wait for master done signal
        @(posedge master_done);
        @(posedge clk);
        #50;

        // Verify master received correct data from slave
        if (master_received == s_data)
            $display("  PASS | Master got 0x%h from slave   (expected 0x%h)",
                      master_received, s_data);
        else
            $display("  FAIL | Master got 0x%h from slave   (expected 0x%h)",
                      master_received, s_data);

        // Verify slave received correct data from master
        if (slave_received == m_data)
            $display("  PASS | Slave  got 0x%h from master  (expected 0x%h)",
                      slave_received, m_data);
        else
            $display("  FAIL | Slave  got 0x%h from master  (expected 0x%h)",
                      slave_received, m_data);

        $display("  ----------------------------------------");

        // Gap between transfers
        repeat(20) @(posedge clk);
    end
endtask

// --- Test Sequence ---
integer pass_count = 0;
integer fail_count = 0;

initial begin
    // Apply reset
    rst = 1;
    repeat(10) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);

    $display("");
    $display("========================================");
    $display("   SPI Controller Verification");
    $display("   Mode 0 | 5MHz SPI | 100MHz Sys Clk");
    $display("========================================");
    $display("");

    // Test 1: Classic alternating patterns
    $display("Test 1 | Alternating bits (0x55 <-> 0xAA)");
    do_transfer(8'h55, 8'hAA, "TEST1");

    // Test 2: All zeros vs all ones
    $display("Test 2 | Boundary values (0x00 <-> 0xFF)");
    do_transfer(8'h00, 8'hFF, "TEST2");

    // Test 3: Inverse pairs
    $display("Test 3 | Inverse pairs (0xA5 <-> 0x5A)");
    do_transfer(8'hA5, 8'h5A, "TEST3");

    // Test 4: Single bit edge cases
    $display("Test 4 | Single bits (0x01 <-> 0x80)");
    do_transfer(8'h01, 8'h80, "TEST4");

    // Test 5: Mixed real values
    $display("Test 5 | Mixed bytes (0xDE <-> 0xAD)");
    do_transfer(8'hDE, 8'hAD, "TEST5");

    $display("");
    $display("========================================");
    $display("   All 5 tests complete");
    $display("========================================");
    $display("");

    #500;
    $finish;
end

// --- Live monitor ---
always @(posedge master_done)
    $display("  [INFO] Transfer complete at %0t ns", $time);

always @(negedge cs_n)
    $display("  [INFO] CS asserted (transfer start) at %0t ns", $time);

endmodule