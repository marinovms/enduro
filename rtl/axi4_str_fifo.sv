//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
//
// Description: 
//
//----------------------------------------------------------------------
//
// Device:
// Block:       
// Designer:    Martin Marinov
//
//----------------------------------------------------------------------
//
// $URL:$
// $Revision:$
// $Date:$
// $Author:$
//
//----------------------------------------------------------------------
`default_nettype none

module axi4_str_fifo #(
    parameter int unsigned ADDR_WDTH = 4,
    parameter int unsigned DATA_WDTH = 8
) (
    input wire                      s_axis_clk,       // Slave AXIS input clock
    input wire                      m_axis_clk,       // Master AXIS output clock 
    
    input wire                      m_axis_aresetn,   // FIFO memory reset – synchronous to s_axis_clk. Active low
    
    input wire [DATA_WDTH-1 :0]     s_axis_tdata,     // Slave (input) AXIS data bus
    input wire                      s_axis_tvalid,    // Slave (input) AXIS data valid flag
    
    input wire                      m_axis_tready,    // Master (output) AXIS ready to receive flag
    
    output wire                     s_axis_tready,    // Slave (input) AXIS ready to receive flag
    
    output wire [DATA_WDTH-1 :0]    m_axis_tdata,     // Master (output) AXIS data bus
    output wire                     m_axis_tvalid     // Master (output) AXIS data valid flag
  ); 
  
//*****************************************************************************
// Local definitions
//*****************************************************************************
wire                  m_bdge_rst_n;

wire                  full;
wire                  empty;
  
wire [ADDR_WDTH :0] wr_ptr_gray;
wire [ADDR_WDTH :0] wr_ptr_bin;

wire [ADDR_WDTH :0] rd_ptr_gray;
wire [ADDR_WDTH :0] rd_ptr_bin;
    
wire [ADDR_WDTH :0] wr_ptr_gray_sync;
wire [ADDR_WDTH :0] rd_ptr_gray_sync;  
   
//*****************************************************************************
//Check configuration validity
//*****************************************************************************
initial begin
  assert (DATA_WDTH === 8 || DATA_WDTH === 16 || DATA_WDTH === 32 || DATA_WDTH === 64) 
  else  
    $fatal(0, "Parameter DATA_WDTH = (%0d) must be 8, 16, 32 or 64 bits wide!", DATA_WDTH);
end   

//*****************************************************************************
//
//*****************************************************************************
wr_fifo_ctrl #(
  .ADDR_WDTH(ADDR_WDTH+1)
)
u_wr_fifo_ctrl (
  .clk        (s_axis_clk         ),

  .rst_n      (1'b1               ),
  .sync_rst_n (m_axis_aresetn     ),
  
  .rd_ptr_gray(rd_ptr_gray_sync   ),  //Read pointer

  .wr_en      (s_axis_tvalid      ),  //Write enable
  .wr_ptr_bin (wr_ptr_bin         ),  //Write pointer - bin value
  .wr_ptr_gray(wr_ptr_gray        ),  //Write pointer - Gray value
  .full       (full               )   //FIFO is full    TODO: check full implementation
);

//*****************************************************************************
//
//*****************************************************************************
dpbuf_mem #(
  .ADDR_WDTH  (ADDR_WDTH  ),
  .DATA_WDTH  (DATA_WDTH  )
)
u_dpbuf_mem (
  .clk_rd     (m_axis_clk ),
  .clk_wr     (s_axis_clk ),

  .wr_en      (s_axis_tvalid & ~full      ),
  .wr_addr    (wr_ptr_bin[ADDR_WDTH-1:0]  ),
  .wr_din     (s_axis_tdata               ),
  
  .rd_en      (~empty                     ),      // TODO: this must be double checked and eventually changed!
  .rd_addr    (rd_ptr_bin[ADDR_WDTH-1:0]  ),

  .rd_dout    (m_axis_tdata               ), 
  .rd_dout_val(m_axis_tvalid              )
  ); 

//*****************************************************************************
//
//*****************************************************************************
rd_fifo_ctrl #(
  .ADDR_WDTH    (ADDR_WDTH+1 )
)
u_rd_fifo_ctrl (
  .clk        (m_axis_clk       ),
  
  .rst_n      (m_bdge_rst_n     ),
  .sync_rst_n (1'b1             ),

  .rd_en      (m_axis_tready    ),
  .wr_ptr_gray(wr_ptr_gray_sync ), //Write pointer
  
  .rd_ptr_bin (rd_ptr_bin       ), //Read pointer - bin value
  .rd_ptr_gray(rd_ptr_gray      ), //Read pointer - Gray value
  
  .empty      (empty            ) //FIFO is empty   TODO: check empty implementation
  ); 

//*****************************************************************************
// rst_n bridge for master (output)
//*****************************************************************************
sync_reg #(
  .SYNC_REG_WDTH        (1  )
)
u_sync_reg_m_rst_n_bdge (
  .clk      (m_axis_clk     ),
  .rst_n    (m_axis_aresetn ),
  .sync_sig (1'b1           ),  
  .sync_reg1(m_bdge_rst_n   )
  );

//*****************************************************************************
// Sync wr Gray pointer
//*****************************************************************************
sync_reg #(
  .SYNC_REG_WDTH  (ADDR_WDTH+1  )
)
u_sync_reg_sync_wr_ptr_g (
  .clk      (m_axis_clk       ),
  .rst_n    (m_bdge_rst_n     ),
  .sync_sig (wr_ptr_gray      ),  
  .sync_reg1(wr_ptr_gray_sync )
  );

//*****************************************************************************
// Sync rd Gray pointer
//*****************************************************************************
 sync_reg #(
  .SYNC_REG_WDTH  (ADDR_WDTH+1  )
)
u_sync_reg_sync_rd_ptr_g (
  .clk      (s_axis_clk       ),
  .rst_n    (m_axis_aresetn   ),
  .sync_sig (rd_ptr_gray      ),  
  .sync_reg1(rd_ptr_gray_sync )
  ); 
 
//*****************************************************************************
// Output assignments
//*****************************************************************************  
assign s_axis_tready = ~full;
  
//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall