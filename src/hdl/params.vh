`ifndef __uart_vh__
`define __uart_vh__

`define SYSCLK_FREQUENCY_HZ 125000000 // Frequency of the sysclk in Hz
`define BAUDRATE 9600 // Baudrate for the transmission
`define DATA_LENGTH 8 // Does not include partity bit
`define DOUBLE_STOPBIT 0 // set 0 for single, 1 for double
`define PARITY 0  // 0 = Disabled, 1 = odd, 2 = even

`endif