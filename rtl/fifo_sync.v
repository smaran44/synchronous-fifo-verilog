`timescale 1ns / 1ps

//=========================================================
// Synchronous FIFO
//=========================================================
module fifo_sync
#(
    parameter FIFO_DEPTH = 8,
    parameter DATA_WIDTH = 32
)
(
    input clk,
    input rst_n,
    input cs,                     // chip select
    input wr_en,                  // write enable
    input rd_en,                  // read enable
    input  [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output empty,
    output full
);

////////////////////////////////////////////////////////////
// Parameter for pointer width
////////////////////////////////////////////////////////////

localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);

////////////////////////////////////////////////////////////
// FIFO Memory
////////////////////////////////////////////////////////////

reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];

////////////////////////////////////////////////////////////
// Read and Write Pointers (extra MSB for full detection)
////////////////////////////////////////////////////////////

reg [FIFO_DEPTH_LOG:0] write_pointer;
reg [FIFO_DEPTH_LOG:0] read_pointer;

////////////////////////////////////////////////////////////
// Write Logic
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        write_pointer <= 0;

    else if (cs && wr_en && !full)
    begin
        fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;
        write_pointer <= write_pointer + 1'b1;
    end
end

////////////////////////////////////////////////////////////
// Read Logic
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        read_pointer <= 0;
        data_out     <= 0;
    end

    else if (cs && rd_en && !empty)
    begin
        data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];
        read_pointer <= read_pointer + 1'b1;
    end
end

////////////////////////////////////////////////////////////
// FIFO Status Logic
////////////////////////////////////////////////////////////

assign empty = (read_pointer == write_pointer);

assign full =
    (read_pointer ==
    {~write_pointer[FIFO_DEPTH_LOG],
     write_pointer[FIFO_DEPTH_LOG-1:0]});

endmodule