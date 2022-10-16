
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 5} [get_ports { clk }];


set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { Dout }]; #IO_L5P_T0_34 Sch=ar[0]
set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { enable }]; #IO_L7N_T1_AD2N_35 Sch=sw[0]
