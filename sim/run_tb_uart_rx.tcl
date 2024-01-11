set scriptDir [file dirname [file normalize [info script]]]

# Directories
set hdlDir $scriptDir/../src/hdl
set tbDir $scriptDir/tb
set simProjDir $scriptDir/proj

# Board options
set board xc7z020
set part xc7z020clg400-1

# Module Information
set dutModule uart_rx
set testbenchFile $tbDir/uart_rx_tb.v
set requiredFiles "
    $hdlDir/uart_rx.v
    $hdlDir/params.vh
"

# Debug option
set debug false

source run_tb.tcl