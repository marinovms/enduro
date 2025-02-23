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
    parameter int unsigned          ADDR_WDTH     = 4,
    parameter string                SYNC_EMPTY_N  = "TRUE" 
) (
    input wire                      clk,
    input wire                      rst_n,
    input wire                      sync_rst_n,

    input wire                      rd_en,
    input wire [ADDR_WDTH-1     :0] wr_ptr_gray,            // Write pointer

    output wire [ADDR_WDTH-1    :0] rd_ptr_gray,            // Read pointer - Gray value
    output wire [ADDR_WDTH-1    :0] rd_ptr_bin,             // Read pointer - bin value
    output wire                     empty_n                 // FIFO is full
);

//*****************************************************************************
// Local definitions
//*****************************************************************************
    integer j;

    reg [ADDR_WDTH-1    :0] rd_ptr;                         // Read pointer counter - bin value
    reg [ADDR_WDTH-1    :0] rd_ptr_old;                     // Old Read pointer counter - bin value

    reg [ADDR_WDTH-1    :0] wr_ptr;                         // Write pointer - bin value

    wire                    empty_w;
    reg                     empty_r;

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
generate
    if (SYNC_EMPTY_N == "TRUE") begin:rd_ptr_gen
    
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <=       {ADDR_WDTH{1'b0}};
            rd_ptr_old <=   {ADDR_WDTH{1'b0}};
        end else if (!sync_rst_n) begin
            rd_ptr <=       {ADDR_WDTH{1'b0}};
            rd_ptr_old <=   {ADDR_WDTH{1'b0}};
        end else begin
            case ({rd_en, empty_w, empty_r})
                {1'b1, 1'b0, 1'b0}: begin
                                        rd_ptr      <= rd_ptr+1;
                                        rd_ptr_old  <= rd_ptr;
                                    end
                default:            begin
                                        rd_ptr      <= rd_ptr;
                                        rd_ptr_old  <= rd_ptr_old;
                                end
            endcase
        end
    end
    
    end else begin
    
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <=       {ADDR_WDTH{1'b0}};
            rd_ptr_old <=   {ADDR_WDTH{1'b0}};
        end else if (!sync_rst_n) begin
            rd_ptr <=       {ADDR_WDTH{1'b0}};
            rd_ptr_old <=   {ADDR_WDTH{1'b0}};
        end else begin
            casez ({rd_en, empty_w, empty_r})
                {1'b1, 1'b0, 1'b?}: begin
                                        rd_ptr      <= rd_ptr+1;
                                        rd_ptr_old  <= rd_ptr;
                                    end
                default:            begin
                                        rd_ptr      <= rd_ptr;
                                        rd_ptr_old  <= rd_ptr_old;
                                end
            endcase
        end
    end
        
    end
endgenerate
    
    assign empty_w = (rd_ptr == wr_ptr);

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            empty_r <= 1'b0;
        end else if (!sync_rst_n) begin
            empty_r <= 1'b0;
        end else begin
            empty_r <= empty_w;
        end
    end

//*****************************************************************************
// Output assignments
//*****************************************************************************
generate
    if (SYNC_EMPTY_N == "TRUE") begin:sync_emptyn
        assign empty_n = ~(empty_w | empty_r) & rd_en;
    end else begin
        assign empty_n = (~empty_w & rd_en) | (~empty_r & rd_en);
    end
endgenerate

assign rd_ptr_bin = rd_ptr;
assign rd_ptr_gray = rd_ptr ^ {1'b0, rd_ptr[ADDR_WDTH-1     :1]};                   // Bin2Gray

//*****************************************************************************
//                                  END OF FILE
//*****************************************************************************
endmodule

`resetall
