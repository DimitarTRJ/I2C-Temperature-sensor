vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/microblaze_v11_0_15
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/proc_sys_reset_v5_0_17
vlib modelsim_lib/msim/lmb_v10_v3_0_15
vlib modelsim_lib/msim/lmb_bram_if_cntlr_v4_0_26
vlib modelsim_lib/msim/blk_mem_gen_v8_4_11
vlib modelsim_lib/msim/iomodule_v3_1_12

vmap xpm modelsim_lib/msim/xpm
vmap microblaze_v11_0_15 modelsim_lib/msim/microblaze_v11_0_15
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap proc_sys_reset_v5_0_17 modelsim_lib/msim/proc_sys_reset_v5_0_17
vmap lmb_v10_v3_0_15 modelsim_lib/msim/lmb_v10_v3_0_15
vmap lmb_bram_if_cntlr_v4_0_26 modelsim_lib/msim/lmb_bram_if_cntlr_v4_0_26
vmap blk_mem_gen_v8_4_11 modelsim_lib/msim/blk_mem_gen_v8_4_11
vmap iomodule_v3_1_12 modelsim_lib/msim/iomodule_v3_1_12

vlog -work xpm  -incr -mfcu  -sv "+incdir+D:/2025.1/Vivado/data/rsb/busdef" \
"D:/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"D:/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work microblaze_v11_0_15  -93  \
"../../../ipstatic/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_0/sim/bd_fc5c_0_microblaze_I_0.vhd" \

vcom -work proc_sys_reset_v5_0_17  -93  \
"../../../ipstatic/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_1/sim/bd_fc5c_0_rst_0_0.vhd" \

vcom -work lmb_v10_v3_0_15  -93  \
"../../../ipstatic/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_2/sim/bd_fc5c_0_ilmb_0.vhd" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_3/sim/bd_fc5c_0_dlmb_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_26  -93  \
"../../../ipstatic/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_4/sim/bd_fc5c_0_dlmb_cntlr_0.vhd" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_5/sim/bd_fc5c_0_ilmb_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_11  -incr -mfcu  "+incdir+D:/2025.1/Vivado/data/rsb/busdef" \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+D:/2025.1/Vivado/data/rsb/busdef" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_6/sim/bd_fc5c_0_lmb_bram_I_0.v" \

vcom -work iomodule_v3_1_12  -93  \
"../../../ipstatic/hdl/iomodule_v3_1_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/ip/ip_7/sim/bd_fc5c_0_iomodule_0_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+D:/2025.1/Vivado/data/rsb/busdef" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/bd_0/sim/bd_fc5c_0.v" \
"../../../../Project01.gen/sources_1/ip/microblaze_mcs_0_2/sim/microblaze_mcs_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

