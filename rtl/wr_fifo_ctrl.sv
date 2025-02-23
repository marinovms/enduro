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
    reg [ADDR_WDTH-1    :0] wr_ptr_old;                     // Old write pointer counter - bin value

    reg [ADDR_WDTH-1    :0] rd_ptr;                         // Read pointer - bin value

    wire [ADDR_WDTH-1   :0] wr_ptr_old_inc;
//    wire [ADDR_WDTH-1   :0] rd_ptr_dec;

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
        if (!rst_n) begin
            wr_ptr      <= {ADDR_WDTH{1'b0}};
            wr_ptr_old  <= {ADDR_WDTH{1'b0}};
        end else if (!sync_rst_n) begin
            wr_ptr      <= {ADDR_WDTH{1'b0}};
            wr_ptr_old  <= {ADDR_WDTH{1'b0}};
        end else begin
            case ({wr_en, full_w})
                {1'b1, 1'b0}:   begin
                                    wr_ptr      <= wr_ptr+1;
                                    wr_ptr_old  <= wr_ptr;
                                end
                default:        begin
                                    wr_ptr      <= wr_ptr;
                                    wr_ptr_old  <= wr_ptr_old;
                                end
            endcase
        end
    end

assign wr_ptr_old_inc = wr_ptr_old+1;
//assign rd_ptr_dec = rd_ptr;                                                       // Need Read-1

assign full_w = (wr_ptr == rd_ptr) & (wr_ptr_old_inc == rd_ptr);

//*****************************************************************************
// Output assignments
//*****************************************************************************
assign full = full_w;
assign wr_ptr_bin = wr_ptr;
assign wr_ptr_gray = wr_ptr ^ {1'b0, wr_ptr[ADDR_WDTH-1     :1]};                   // Bin2Gray

//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall
