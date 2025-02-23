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

module sync_reg #(
    parameter int unsigned  SYNC_REG_WDTH = 1
//    parameter logic                   [SYNC_REG_WDTH-1  :0] RST_VAL       = 'h0
) (
                            input wire                              clk,
                            input wire                              rst_n,
                            input wire [SYNC_REG_WDTH-1         :0] sync_sig,
(* ASYNC_REG = "TRUE" *)    output reg [SYNC_REG_WDTH-1         :0] sync_reg1
);

//*****************************************************************************
// Local defines
//*****************************************************************************
(* ASYNC_REG = "TRUE" *)    reg [SYNC_REG_WDTH-1      :0] sync_reg0 = {SYNC_REG_WDTH{1'b0}};
//(* ASYNC_REG = "TRUE" *)    reg [SYNC_REG_WDTH-1      :0] sync_reg1;

//*****************************************************************************
// CDC sync
//*****************************************************************************


    always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        sync_reg0 <= {SYNC_REG_WDTH{1'b0}};
        sync_reg1 <= {SYNC_REG_WDTH{1'b0}};
      end 
      else begin
        sync_reg0 <= sync_sig;
        sync_reg1 <= sync_reg0;
      end 
    end

//*****************************************************************************
// Output assignments
//*****************************************************************************
//assign synced_sig = sync_reg1;


//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall
