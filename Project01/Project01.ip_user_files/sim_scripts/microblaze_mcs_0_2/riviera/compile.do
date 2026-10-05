transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/microblaze_v11_0_15
vlib riviera/xil_defaultlib
vlib riviera/proc_sys_reset_v5_0_17
vlib riviera/lmb_v10_v3_0_15
vlib riviera/lmb_bram_if_cntlr_v4_0_26
vlib riviera/blk_mem_gen_v8_4_11
vlib riviera/iomodule_v3_1_12

vmap xpm riviera/xpm
vmap microblaze_v11_0_15 riviera/microblaze_v11_0_15
vmap xil_defaultlib riviera/xil_defaultlib
vmap proc_sys_reset_v5_0_17 riviera/proc_sys_reset_v5_0_17
vmap lmb_v10_v3_0_15 riviera/lmb_v10_v3_0_15
vmap lmb_bram_if_cntlr_v4_0_26 riviera/lmb_bram_if_cntlr_v4_0_26
vmap blk_mem_gen_v8_4_11 riviera/blk_mem_gen_v8_4_11
vmap iomodule_v3_1_12 riviera/iomodule_v3_1_12

vlog -work xpm  -incr "+incdir+D:/2025.1/Vivado/data/rsb/busdef" -l xpm -l microblaze_v11_0_15 -l xil_defaultlib -l proc_sys_reset_v5_0_17 -l lmb_v10_v3_0_15 -l lmb_bram_if_cntlr_v4_0_26 -l blk_mem_gen_v8_4_11 -l iomodule_v3_1_12 \
"D:/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"D:/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work microblaze_v11_0_15 -93  -incr \
"../../../ipstatic/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_0/sim/bd_fc5c_0_microblaze_I_0.vhd" \

vcom -work proc_sys_reset_v5_0_17 -93  -incr \
"../../../ipstatic/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_1/sim/bd_fc5c_0_rst_0_0.vhd" \

vcom -work lmb_v10_v3_0_15 -93  -incr \
"../../../ipstatic/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_2/sim/bd_fc5c_0_ilmb_0.vhd" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_3/sim/bd_fc5c_0_dlmb_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_26 -93  -incr \
"../../../ipstatic/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_4/sim/bd_fc5c_0_dlmb_cntlr_0.vhd" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_5/sim/bd_fc5c_0_ilmb_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_11  -incr -v2k5 "+incdir+D:/2025.1/Vivado/data/rsb/busdef" -l xpm -l microblaze_v11_0_15 -l xil_defaultlib -l proc_sys_reset_v5_0_17 -l lmb_v10_v3_0_15 -l lmb_bram_if_cntlr_v4_0_26 -l blk_mem_gen_v8_4_11 -l iomodule_v3_1_12 \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+D:/2025.1/Vivado/data/rsb/busdef" -l xpm -l microblaze_v11_0_15 -l xil_defaultlib -l proc_sys_reset_v5_0_17 -l lmb_v10_v3_0_15 -l lmb_bram_if_cntlr_v4_0_26 -l blk_mem_gen_v8_4_11 -l iomodule_v3_1_12 \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_6/sim/bd_fc5c_0_lmb_bram_I_0.v" \

vcom -work iomodule_v3_1_12 -93  -incr \
"../../../ipstatic/hdl/iomodule_v3_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_7/sim/bd_fc5c_0_iomodule_0_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+D:/2025.1/Vivado/data/rsb/busdef" -l xpm -l microblaze_v11_0_15 -l xil_defaultlib -l proc_sys_reset_v5_0_17 -l lmb_v10_v3_0_15 -l lmb_bram_if_cntlr_v4_0_26 -l blk_mem_gen_v8_4_11 -l iomodule_v3_1_12 \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/sim/bd_fc5c_0.v" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/sim/microblaze_mcs_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

