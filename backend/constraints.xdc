
create_clock -period 1000 -name s_axis_clk -waveform {0.000 500} [get_ports s_axis_clk]
create_clock -period 3000 -name m_axis_clk -waveform {0.000 1500} [get_ports m_axis_clk]

set_clock_groups -asynchronous \
        -group {s_axis_clk} \
        -group {m_axis_clk}

#set_false_path -from  [get_pins -hier -filter {NAME =~ */u_sync_reg_m_rst_n_bdge/m_bdge_rst_n}]
