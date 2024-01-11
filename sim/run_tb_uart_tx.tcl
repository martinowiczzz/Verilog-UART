set scriptDir [file dirname [file normalize [info script]]]

# Directories
set hdlDir $scriptDir/../src/hdl
set tbDir $scriptDir/tb
set simProjDir $scriptDir/proj

# Board options
set board xc7z020
set part xc7z020clg400-1

# Module Information
set dutModule uart_tx
set testbenchFile $tbDir/uart_tx_tb.v
set requiredFiles "
    $hdlDir/uart_tx.v
    $hdlDir/params.vh
"

# Debug option
set debug true

source run_tb.tcl