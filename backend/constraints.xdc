
create_clock -period 20 -name s_axis_clk -waveform {0.0 10.0} [get_ports s_axis_clk]
create_clock -period 30 -name m_axis_clk -waveform {0.0 15.0} [get_ports m_axis_clk]

set_clock_groups -asynchronous \
        -group {s_axis_clk} \
        -group {m_axis_clk}

#set_false_path -from  [get_pins -hier -filter {NAME =~ */u_sync_reg_m_rst_n_bdge/m_bdge_rst_n}]
