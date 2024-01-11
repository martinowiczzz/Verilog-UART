# Prepare directories
set projDir $simProjDir/${dutModule}_sim
file delete -force $projDir
file mkdir $projDir

# Project mode required for automatic generation of scripts.
# Non=project mode does not allow the usage of launch_simulation.
# See UG900 (v2021.2) Chapter 7 "Running the Vivado Simulator in Batch Mode", p. 144
create_project ${dutModule}_sim $projDir -part $part
add_files -norecurse $requiredFiles
add_files -fileset sim_1 -norecurse $testbenchFile
import_files -force -norecurse
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_simulation
if {$debug} {
    start_gui
} else {
    close_sim
    close_project
}
