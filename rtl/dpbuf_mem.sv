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

module dpbuf_mem #(
    parameter int unsigned          ADDR_WDTH = 4,
    parameter int unsigned          DATA_WDTH = 8
) (
    input wire                      clk_rd,
    input wire                      clk_wr,

//    input wire                      reset,
//    input wire                      sync_reset,

    input wire [ADDR_WDTH-1     :0] wr_addr,
    input wire [ADDR_WDTH-1     :0] rd_addr,

    input wire                      wr_en,
    input wire                      rd_en,

    input wire [DATA_WDTH-1     :0] wr_din,
    output wire [DATA_WDTH-1    :0] rd_dout,

    output wire                     rd_dout_val
);

//*****************************************************************************
// Local definitions
//*****************************************************************************
    localparam MEM_SIZE = (1 << ADDR_WDTH);

(* ram_style = "block" *)    reg [DATA_WDTH-1    :0] dpbuf_mem [MEM_SIZE-1     :0];

    reg [DATA_WDTH-1    :0] dout;
    reg                     rd_dout_val_r;

//*****************************************************************************
// Sync mem write
//*****************************************************************************
    always @(posedge clk_wr) begin
        if (wr_en) begin
            dpbuf_mem[wr_addr] <= wr_din;
        end
    end

//*****************************************************************************
// Sync mem read
//*****************************************************************************
    always @(posedge clk_rd) begin
        if (rd_en) begin
            dout <= dpbuf_mem[rd_addr];
        end
    end

//*****************************************************************************
// Data valid
//*****************************************************************************
    always @(posedge clk_rd/*, posedge reset*/) begin
//        if (reset) begin
//            rd_dout_val_r <= 1'b0;
//        end else if (sync_reset) begin
//            rd_dout_val_r <= 1'b0;
//        end else begin
            rd_dout_val_r <= rd_en;
//        end
    end

assign rd_dout_val =    rd_dout_val_r;
assign rd_dout =        dout;

//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall
