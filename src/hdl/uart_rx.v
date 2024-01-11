`include "params.vh"
module uart_rx #(
   parameter integer SYSCLK_FREQUENCY_HZ = `SYSCLK_FREQUENCY_HZ,
   parameter integer BAUDRATE = `BAUDRATE, 
   // Ratio has to be whole and even or large enough. Must be >2, as otherwise there is no time to switch to STATE_CHECK. 
   parameter integer DATA_LENGTH = `DATA_LENGTH,
   parameter DOUBLE_STOPBIT = `DOUBLE_STOPBIT,
   parameter [1:0] PARITY = `PARITY
) (sysclk, serial, active, ready, error, data);

   // Parameters
   //
   localparam [1:0] STATE_IDLE = 2'd0;
   localparam [1:0] STATE_RX = 2'd1;
   localparam [1:0] STATE_STOP = 2'd2;
   localparam [1:0] STATE_CHECK = 2'd3;
   //
   localparam integer RX_LENGTH = PARITY ? DATA_LENGTH+1 : DATA_LENGTH;
   localparam integer RX_IDX_WIDTH = $clog2(RX_LENGTH);
   localparam integer CLK_CYCLES_PER_SYMBOL = (SYSCLK_FREQUENCY_HZ / BAUDRATE);
   localparam integer UART_CYCLE_CNT_WIDTH = $clog2(CLK_CYCLES_PER_SYMBOL);
   
   // Inputs
   //
   input sysclk;
   input serial;

   // Outputs
   //
   output reg active;
   output reg ready;
   output reg error;
   output [DATA_LENGTH-1:0] data;

   // Internal nets
   //
   reg [RX_LENGTH-1:0] i_data = 0;
   reg [1:0] state = STATE_IDLE;
   reg [RX_IDX_WIDTH-1:0] rx_idx = 0;
   reg recv_stop = 0;
   reg [UART_CYCLE_CNT_WIDTH-1:0] uart_cycle_cnt = 0;

   always @(posedge sysclk) begin
      case (state)
         STATE_IDLE: begin
            recv_stop <= 1'b0;
            error <= 1'b0;
            ready <= 1'b0;
            rx_idx <= 3'd0;
            if (serial == 1'b0) begin
               active <= 1'b1;
               if (uart_cycle_cnt == CLK_CYCLES_PER_SYMBOL/2) begin
                  uart_cycle_cnt <= 0;
                  state <= STATE_RX;
               end else begin
                  uart_cycle_cnt <= uart_cycle_cnt + 1;
               end
            end else begin
               // Abort init
               uart_cycle_cnt <= 0;
               active <= 1'b0;
            end
         end

         STATE_RX: begin
            if (uart_cycle_cnt == CLK_CYCLES_PER_SYMBOL-1) begin
               i_data[rx_idx] <= serial;
               if (rx_idx == RX_LENGTH-1) begin
                  state <= STATE_STOP;
               end
               rx_idx <= rx_idx+1;
               uart_cycle_cnt <= 0;
            end else begin
               uart_cycle_cnt <= uart_cycle_cnt + 1;
            end
         end

         STATE_STOP: begin
            // TODO: Timeout after some clock cycles. Send error and go back to idle
            if (uart_cycle_cnt == CLK_CYCLES_PER_SYMBOL-1) begin
               if (serial == 1'b1) begin
                  if (DOUBLE_STOPBIT && !recv_stop) begin
                     recv_stop <= 1'b1;
                  end else begin
                     state <= STATE_CHECK;
                  end
                  uart_cycle_cnt <= 0;
               end
            end else begin
               uart_cycle_cnt <= uart_cycle_cnt + 1;
            end
         end
         
         STATE_CHECK: begin
            if (uart_cycle_cnt == (CLK_CYCLES_PER_SYMBOL-1)/2 - 1) begin
               error <= PARITY && (PARITY[0] ^ (^i_data));
               ready <= 1'b1;
               uart_cycle_cnt <= 0;
               active <= 1'b0;
               state <= STATE_IDLE;
            end else begin
               uart_cycle_cnt <= uart_cycle_cnt + 1;
            end       
         end

         default: begin
            i_data <= 0;
            active <= 1'b0;
            uart_cycle_cnt <= 0;
            state <= STATE_IDLE;
         end
      endcase
   end
   //
   assign data = i_data[DATA_LENGTH-1:0];

endmodule
