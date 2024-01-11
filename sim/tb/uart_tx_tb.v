`timescale 1ns/1ps
module uart_tx_tb;

   // Parameters
   //
   localparam integer EDGE_PERIOD = 5;
   localparam integer CLK_PERIOD = 2*EDGE_PERIOD;
   //
   // Only relation to baudrate matters, so can be low for simulation purposes
   localparam integer SYSCLK_FREQUENCY_HZ = 4;
   localparam integer BAUDRATE = 1;
   localparam integer RATIO = SYSCLK_FREQUENCY_HZ / BAUDRATE;
   //
   localparam PARITY = 1'b1;
   localparam DOUBLE_STOPBIT = 1'b0;
   
   // DUT Inputs
   //
   reg sysclk = 1;
   reg start = 0;
   reg [7:0] data = 1;

   // DUT Outputs
   //
   wire ready;
   wire serial;

   // Generate clock
   //
   always #EDGE_PERIOD sysclk=~sysclk;

   // DUT
   uart_tx #(
      .SYSCLK_FREQUENCY_HZ(SYSCLK_FREQUENCY_HZ),
      .BAUDRATE(BAUDRATE),
      .DATA_LENGTH(8),
      .DOUBLE_STOPBIT(DOUBLE_STOPBIT),
      .PARITY(PARITY)
   ) u_dut (
      .sysclk(sysclk),
      .start(start),
      .data(data),
      .ready(ready),
      .serial(serial)
   );

   task sim_tx;
      input [7:0] rx_data;
      input parity;
      input double_stopbit;
      begin
         $display("Signal '%s'. Actual: %b, expected: %b", "serial (idle)", serial, 1'b1);
         data = rx_data;
         start = 1'b1;
         #(CLK_PERIOD);
         start = 1'b0;
         $display("Signal '%s'. Actual: %b, expected: %b", "serial (start bit)", serial, 1'b0);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[0]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[1]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[2]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[3]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[4]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[5]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[6]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial", serial, rx_data[7]);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial (parity)", serial, parity);
         #(RATIO*CLK_PERIOD);
         $display("Signal '%s'. Actual: %b, expected: %b", "serial (stop bit)", serial, 1'b1);
         if (double_stopbit) begin
            #(RATIO*CLK_PERIOD);
            $display("Signal '%s'. Actual: %b, expected: %b", "serial (stop bit)", serial, 1'b1);
         end
      end
   endtask

   initial begin
      #(2*CLK_PERIOD);
      // Test 1 - No error
      $display("Executing Test 1.");
      sim_tx(8'b10100111, 1'b0, 1'b0);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b1);
      #(CLK_PERIOD);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b0);
      $display("Signal '%s'. Actual: %b, expected: %b", "serial (idle)", serial, 1'b1);
      #(CLK_PERIOD);
      $display("Signal '%s'. Actual: %b, expected: %b", "serial (idle)", serial, 1'b1);
      #(CLK_PERIOD);
      $display("Signal '%s'. Actual: %b, expected: %b", "serial (idle)", serial, 1'b1);
      #(CLK_PERIOD);
      // Test 2 - Bitflip
      $display("Executing Test 2.");
      sim_tx(8'b00100111, 1'b1, 1'b0);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b1);
      #(CLK_PERIOD);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b0);
      #(CLK_PERIOD);
      $stop;
   end

endmodule