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

module wr_fifo_ctrl #(
    parameter int unsigned          ADDR_WDTH = 4
)(
    input wire                      clk,
    input wire                      rst_n,
    input wire                      sync_rst_n,

    input wire                      wr_en,                  // Write enble
    input wire [ADDR_WDTH-1     :0] rd_ptr_gray,            // Read pointer

    output wire [ADDR_WDTH-1    :0] wr_ptr_gray,            // Write pointer - Gray value
    output wire [ADDR_WDTH-1    :0] wr_ptr_bin,             // Write pointer - bin value
    output wire                     full                    // FIFO is full
);

//*****************************************************************************
// Local definitions
//*****************************************************************************
    integer j;

    reg [ADDR_WDTH-1    :0] wr_ptr;                         // Write pointer counter - bin value
    reg [ADDR_WDTH-1    :0] rd_ptr;                         // Read pointer - bin value
    wire                    full_w;                         // FIFO full

//*****************************************************************************
// Rd pointer Gray2Bin
//*****************************************************************************
    always @(*) begin
        rd_ptr[ADDR_WDTH-1] = rd_ptr_gray[ADDR_WDTH-1];

        for (j=ADDR_WDTH-2; j>=0; j = j-1) begin
            rd_ptr[j] = rd_ptr_gray[j] ^ rd_ptr[j+1];
        end
    end

//*****************************************************************************
// Write pointer - binary
//*****************************************************************************
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            wr_ptr      <= {ADDR_WDTH{1'b0}};
        else if (!sync_rst_n)
            wr_ptr      <= {ADDR_WDTH{1'b0}};
        else begin
            case ({wr_en, full_w})
                {1'b1, 1'b0}: wr_ptr <= wr_ptr + {{(ADDR_WDTH-1){1'b0}}, 1'b1};
                default:      wr_ptr <= wr_ptr;
            endcase
        end
    end

    assign full_w = (rd_ptr[ADDR_WDTH-1] ^ wr_ptr[ADDR_WDTH-1]) & (rd_ptr[ADDR_WDTH-2:0] == wr_ptr[ADDR_WDTH-2:0]);

//*****************************************************************************
// Output assignments
//*****************************************************************************
    assign full = full_w;
    assign wr_ptr_bin = wr_ptr;

// This could be FF-ed as well
    assign wr_ptr_gray = wr_ptr ^ (wr_ptr >> 1);                   // Bin2Gray

//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall
