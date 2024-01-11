# UART RX/TX
This repository provides an RTL implementation of a UART receiver and a UART transmitter in Verilog.

## Module: uart_rx
This module implements a UART receiver. Upon detecting a start bit in `serial`, the logic starts probing the signal according to the set baudrate. For better stability, it synchronises in such a way, that the signal is probed in the middle of the time frame for each bit. After the full single frame (incl. start, data, parity and stop bits) has been received, the `ready` signal is raised for one clock cycle of `sysclk`. While receiving, the `active` signal is raised.

### Parameters
| Name                   | Expected Values | Description |
|------------------------|----------------|--------------|
| `SYSCLK_FREQUENCY_HZ`  | Integers | The frequency of the `sysclk` in Hertz. |
| `BAUDRATE`             | Integers | The baudrate of the transmitter. |
| `DATA_LENGTH`          | Integers | The amount of data bits per transmission (not including start, parity or stop-bits).  | 
| `DOUBLE_STOPBIT`       | 0, 1     | Set `1` if the transmitter sends two stop bits. |
| `PARITY`               | 0, 1, 2  | Set `0` for none, `1` for odd or `2` for even parity bits send by the transmitter. |

### Inputs/Outputs
| Name       | Width         | Description |
|------------|---------------|-------------|
| `sysclk`   | 1             | Clock signal for the receiver (frequency should be significantly faster than the UART baudrate). |
| `serial`   | 1             | UART data signal. |
| `active`   | 1             | Raised while the module is busy receiving a transmission. |
| `ready`    | 1             | Raised for one clock cycle after the transmission has ended and the module becomes ready again. |
| `error`    | 1             | Raised for one clock cycle, simultaneously to `ready`, if `PARITY` is enabled and wrong data is detected. |
| `data`     | `DATA_LENGTH` | The data received in the previous transmission. Should be read as soon as `ready` is raised, as it is overwritten during the next transmission. |

## Module: uart_tx
This module implements a UART transmitter. When setting `start` to high for exactly one clock cycle, the logic forwards the bits in `data` through `serial` according to the set baudrate. After the transmission has been finished, the `ready` signal is raised for one clock cycle of `sysclk`. While transmitting, `data` should be kept stable.

### Parameters
| Name                   | Expected Values | Description |
|------------------------|----------------|--------------|
| `SYSCLK_FREQUENCY_HZ`  | Integers | The frequency of the `sysclk` in Hertz. |
| `BAUDRATE`             | Integers | The targetted baudrate. |
| `DATA_LENGTH`          | Integers | The amount of data bits per transmission (not including start, parity or stop-bits).  | 
| `DOUBLE_STOPBIT`       | 0, 1     | Set `1` to send two stop bits. |
| `PARITY`               | 0, 1, 2  | Set `0` for none, `1` for odd or `2` for even parity. |

### Inputs/Outputs
| Name       | Width         | Description |
|------------|---------------|-------------|
| `sysclk`   | 1             | Clock signal for the receiver (frequency should be significantly faster than the UART baudrate) |
| `start`    | 1             | Start the data transmission. |
| `data`     | `DATA_LENGTH` | The data to be transmitted. Should be kept stable during the transmission. |
| `serial`   | 1             | UART data signal. |
| `ready`    | 1             | Raised for one clock cycle after the transmission has ended and the module becomes ready again. | 
