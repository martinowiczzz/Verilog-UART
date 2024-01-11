`include "params.vh"
module uart_tx #(
   parameter integer SYSCLK_FREQUENCY_HZ = `SYSCLK_FREQUENCY_HZ,
   parameter integer BAUDRATE = `BAUDRATE, 
   parameter integer DATA_LENGTH = `DATA_LENGTH,
   parameter DOUBLE_STOPBIT = `DOUBLE_STOPBIT,
   parameter [1:0] PARITY = `PARITY
) (sysclk, start, data, ready, serial);

   // Parameters
   //
   localparam [1:0] STATE_IDLE = 2'd0;
   localparam [1:0] STATE_TX = 2'd1;
   localparam [1:0] STATE_PARITY = 2'd2;
   localparam [1:0] STATE_STOP = 2'd3;
   //
   localparam integer DATA_IDX_WIDTH = $clog2(DATA_LENGTH);
   localparam integer CLK_CYCLES_PER_SYMBOL = (SYSCLK_FREQUENCY_HZ / BAUDRATE);
   localparam integer UART_CYCLE_CNT_WIDTH = $clog2(CLK_CYCLES_PER_SYMBOL);
   
   // Inputs
   //
   input sysclk;
   input start;
   input [DATA_LENGTH-1:0] data;

   // Outputs
   //
   output reg ready;
   output reg serial = 1'b1;

   // Internal nets
   //
   reg [1:0] state = STATE_IDLE;
   reg [DATA_IDX_WIDTH-1:0] data_idx = 0;
   reg sent_stop = 0;
   reg [UART_CYCLE_CNT_WIDTH-1:0] uart_cycle_cnt = 0;

   always @(posedge sysclk) begin
      case (state)
         STATE_IDLE: begin
            sent_stop <= 1'b0;
            ready <= 1'b0;
            data_idx <= 3'd0;
            uart_cycle_cnt <= 0;
            if (start) begin
               serial <= 1'b0; // Send start bit
               state <= STATE_TX;
            end
         end

         STATE_TX: begin
            if (uart_cycle_cnt == CLK_CYCLES_PER_SYMBOL-1) begin
               serial <= data[data_idx];
               if (data_idx == DATA_LENGTH-1) begin
                  state <= PARITY ? STATE_PARITY : STATE_STOP;
               end
               uart_cycle_cnt <= 0;
               data_idx <= data_idx+1;
            end else begin
               uart_cycle_cnt <= uart_cycle_cnt + 1;
            end
         end

         STATE_PARITY: begin
            if (uart_cycle_cnt == CLK_CYCLES_PER_SYMBOL-1) begin
               serial <= PARITY[0] ^ (^data);
               uart_cycle_cnt <= 0;
               state <= STATE_STOP;
            end else begin
               uart_cycle_cnt <= uart_cycle_cnt + 1;
            end
         end

         STATE_STOP: begin
            if (uart_cycle_cnt == CLK_CYCLES_PER_SYMBOL-1) begin
               if (DOUBLE_STOPBIT && !sent_stop) begin
                  serial <= 1'b1; // Send first stop bit
                  sent_stop <= 1'b1;
                  uart_cycle_cnt <= 0;
               end else begin
                  serial <= 1'b1; // Send stop bit
                  ready <= 1'b1;
                  uart_cycle_cnt <= 0;
                  state <= STATE_IDLE;
               end
            end else begin
               uart_cycle_cnt <= uart_cycle_cnt + 1;
            end
         end

         default: begin
            serial <= 1'b1;
            uart_cycle_cnt <= 0;
            sent_stop <= 1'b0;
            ready <= 1'b0;
            state <= STATE_IDLE;
         end
    endcase
  end
endmodule
