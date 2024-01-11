`timescale 1ns/1ps
module uart_rx_tb;

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
   reg serial = 1;

   // DUT1 Outputs
   //
   wire active;
   wire ready;
   wire error;
   wire [7:0] data;

   // Generate clock
   //
   always #EDGE_PERIOD sysclk=~sysclk;

   // DUT1
   uart_rx #(
      .SYSCLK_FREQUENCY_HZ(SYSCLK_FREQUENCY_HZ),
      .BAUDRATE(BAUDRATE),
      .DATA_LENGTH(8),
      .DOUBLE_STOPBIT(DOUBLE_STOPBIT),
      .PARITY(PARITY)
   ) u_dut (
      .sysclk(sysclk),
      .serial(serial),
      .active(active),
      .ready(ready),
      .error(error),
      .data(data)
   );

   task sim_rx;
      input [8:0] rx_data;
      input parity;
      input double_stopbit;
      begin
         serial = 1'b0; // Start bit
         #(RATIO*CLK_PERIOD);
         serial = rx_data[0];
         #(RATIO*CLK_PERIOD);
         serial = rx_data[1];
         #(RATIO*CLK_PERIOD);
         serial = rx_data[2];
         #(RATIO*CLK_PERIOD);
         serial = rx_data[3];
         #(RATIO*CLK_PERIOD);
         serial = rx_data[4];
         #(RATIO*CLK_PERIOD);
         serial = rx_data[5];
         #(RATIO*CLK_PERIOD);
         serial = rx_data[6];
         #(RATIO*CLK_PERIOD);
         serial = rx_data[7];
         #(RATIO*CLK_PERIOD);
         if (parity) begin
            serial = rx_data[8]; // Parity bit
            #(RATIO*CLK_PERIOD);
         end
         serial = 1'b1; // Stop bit
         #(RATIO*CLK_PERIOD);
         if (double_stopbit) begin
            serial = 1'b1; // Second stop bit
            #(RATIO*CLK_PERIOD);
         end
      end
   endtask

   initial begin
      #(3*CLK_PERIOD);
      // Test 1.1 - No error
      $display("Executing Test 1.1");
      sim_rx(9'b0_10100111, PARITY, DOUBLE_STOPBIT);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b1);
      $display("Signal '%s'. Actual: %b, expected: %b", "error", error, 1'b0);
      $display("Signal '%s'. Actual: %b, expected: %b", "data", data, 8'b10100111);
      #(CLK_PERIOD);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b0);
      $display("Signal '%s'. Actual: %b, expected: %b", "error", error, 1'b0);
      #(3*CLK_PERIOD);
      // Test 1.2 - Bitflip
      $display("Executing Test 1.2");
      sim_rx(9'b0_00100111, PARITY, DOUBLE_STOPBIT);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b1);
      $display("Signal '%s'. Actual: %b, expected: %b", "error", error, 1'b1);
      $display("Signal '%s'. Actual: %b, expected: %b", "data", data, 8'b00100111);
      #(CLK_PERIOD);
      $display("Signal '%s'. Actual: %b, expected: %b", "ready", ready, 1'b0);
      $display("Signal '%s'. Actual: %b, expected: %b", "error", error, 1'b0);
      #(3*CLK_PERIOD);
      $stop;
   end

endmodule