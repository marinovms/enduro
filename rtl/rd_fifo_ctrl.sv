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

module rd_fifo_ctrl #(
    parameter int unsigned          ADDR_WDTH = 4 
) (
    input wire                      clk,
    input wire                      rst_n,
    input wire                      sync_rst_n,

    input wire                      rd_en,
    input wire [ADDR_WDTH-1     :0] wr_ptr_gray,            // Write pointer

    output wire [ADDR_WDTH-1    :0] rd_ptr_gray,            // Read pointer - Gray value
    output wire [ADDR_WDTH-1    :0] rd_ptr_bin,             // Read pointer - bin value
    output wire                     empty                   // FIFO is full
);

//*****************************************************************************
// Local definitions
//*****************************************************************************
    integer j;

    reg [ADDR_WDTH-1    :0] rd_ptr;                         // Read pointer counter - bin value
    reg [ADDR_WDTH-1    :0] wr_ptr;                         // Write pointer - bin value
    wire                    empty_w;

//*****************************************************************************
// Wr pointer Gray2Bin
//*****************************************************************************
    always @(*) begin
        wr_ptr[ADDR_WDTH-1] = wr_ptr_gray[ADDR_WDTH-1];

        for (j=ADDR_WDTH-2; j>=0; j = j-1) begin
            wr_ptr[j] = wr_ptr_gray[j] ^ wr_ptr[j+1];
        end
    end

//*****************************************************************************
// Rd pointer binary
//*****************************************************************************   
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= {ADDR_WDTH{1'b0}};
        end else if (!sync_rst_n) begin
            rd_ptr <= {ADDR_WDTH{1'b0}};
        end else begin
            case ({rd_en, empty_w})
                {1'b1, 1'b0}: begin
                                rd_ptr <= rd_ptr + {{(ADDR_WDTH-1){1'b0}}, 1'b1};
                end 
                default:      begin
                                rd_ptr <= rd_ptr;
                end 
            endcase
        end
    end
    
    assign empty_w = (rd_ptr == wr_ptr);

//*****************************************************************************
// Output assignments
//*****************************************************************************
    assign empty      = empty_w;
    assign rd_ptr_bin = rd_ptr;
    
// This could be FF-ed as well
    assign rd_ptr_gray = rd_ptr ^ (rd_ptr >> 1);                   // Bin2Gray

//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall
