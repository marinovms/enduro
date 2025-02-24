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
`timescale 1ns/1ns

module tb();


//=============================================================================
// Local definitions
//=============================================================================
localparam int unsigned SAXIS_CLKIN_PERIOD  = 1000;
localparam int unsigned MAXIS_CLKIN_PERIOD  = 3400;  
localparam int unsigned RESET_PERIOD        = 20000;

localparam int unsigned ADDR_WDTH = 3;
localparam int unsigned DATA_WDTH = 8;

reg m_axis_aresetn;
reg s_axis_clk;
reg m_axis_clk;
  
reg [DATA_WDTH-1  :0] s_axis_tdata;    
reg                   s_axis_tvalid;
wire                  s_axis_tready;
    
wire [DATA_WDTH-1 :0] m_axis_tdata;
wire                  m_axis_tvalid;
reg                   m_axis_tready;
  

//*****************************************************************************
// Clock & Reset_N
//*****************************************************************************
    initial begin
        m_axis_aresetn = 1'b1;
        @(posedge s_axis_clk)
          m_axis_aresetn = 1'b0;
        #RESET_PERIOD
        @(posedge s_axis_clk)
          m_axis_aresetn = 1'b1;
          $display("ResetN deasserted...");      
    end


    initial begin
        s_axis_clk = 1'b0;
        m_axis_clk = 1'b0;
    end 
    
    always
      s_axis_clk = #(SAXIS_CLKIN_PERIOD/2) ~s_axis_clk;

    always
      m_axis_clk = #(MAXIS_CLKIN_PERIOD/2) ~m_axis_clk;

//*****************************************************************************
// Initial control & data signals
//*****************************************************************************
    initial begin
      s_axis_tdata = 'h0;
      s_axis_tvalid = 1'b0;
    end

//*****************************************************************************
// Stimuli
//*****************************************************************************
    initial begin
    
    m_axis_tready = 1'b0;
      
    #(5*RESET_PERIOD);    
    wr_data ('hBA);
      
    #100us;
    wr_data ('hDA);

    #100us;
    wr_data ('hFA);
      
    #100us;
    wr_data ('h55);      

    #100us;
    wr_data ('h01); 
      
    #100us;
    wr_data ('h02); 
      
    #100us;
    wr_data ('h03);       

    #100us;
    wr_data ('h04); 
      
    #100us; 
    @(posedge m_axis_clk);
      m_axis_tready = 1'b1;
      
    #1ms; // Here the FIFO should be streamed out
      
    @(posedge m_axis_clk);
      m_axis_tready = 1'b0;
    
    #100us;  
    wr_data ('h11);

    #100us;
    wr_data ('hCE);
      
    #100us;
    wr_data ('hCA);      

    #100us;
    wr_data ('hFE); 
      
    #100us;
    wr_data ('hDE); 
      
    #100us;
    wr_data ('h22);       

    #100us;
    wr_data ('h33);       
      
    #100us;
    wr_data ('h88); 

// Extra write -> must not be accepted
//    #100us;
//    wr_data ('h9A);  
      

    #100us; 
    @(posedge m_axis_clk);
      m_axis_tready = 1'b1;
      
    #1ms; // Here the FIFO should be streamed out
      
    @(posedge m_axis_clk);
      m_axis_tready = 1'b0;      
    
     
    #500us; 
    $stop;
    end 

//*****************************************************************************
// 
//*****************************************************************************
axi4_str_fifo #(
  .ADDR_WDTH(ADDR_WDTH),
  .DATA_WDTH(DATA_WDTH)
)
u_axi4_str_fifo (
  .m_axis_aresetn(m_axis_aresetn),  //FIFO memory reset – synchronous to s_axis_clk. Active low
  .m_axis_clk    (m_axis_clk),      //Master AXIS output clock
  .s_axis_clk    (s_axis_clk),      //Slave AXIS input clock  

  .s_axis_tdata  (s_axis_tdata),    //Slave (input) AXIS data bus
  .s_axis_tvalid (s_axis_tvalid),   //Slave (input) AXIS data valid flag
  .s_axis_tready (s_axis_tready),   //Slave (input) AXIS ready to receive flag

  .m_axis_tdata  (m_axis_tdata),
  .m_axis_tvalid (m_axis_tvalid),   //Master (output) AXIS data valid flag  
  .m_axis_tready (m_axis_tready)    //Master (output) AXIS ready to receive flag
  ); 

//*****************************************************************************
// 
//*****************************************************************************

  task automatic wr_data;
      input [DATA_WDTH-1  :0] data;
  begin
      @(posedge s_axis_clk);
        s_axis_tdata  <= data;
        s_axis_tvalid <= 1'b1;
      @(posedge s_axis_clk) begin
        wait (s_axis_tready);
        s_axis_tvalid <= 1'b0;
      end  
  end 
  endtask


//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall
