`timescale 1ns / 1ps

// Synchronous FIFO

module fifo_sync
#(
    parameter FIFO_DEPTH  = 8,
    parameter DATA_WIDTH  = 32,
    parameter ALMOST_FULL_THRESHOLD  = FIFO_DEPTH - 2,
    parameter ALMOST_EMPTY_THRESHOLD = 2
)
(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  cs,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] data_in,

    output reg  [DATA_WIDTH-1:0] data_out,
    output wire                  empty,
    output wire                  full,
    output wire                  almost_empty,
    output wire                  almost_full,
    output wire [PTR_WIDTH:0]    fill_count
);

// Local Parameters

localparam PTR_WIDTH = $clog2(FIFO_DEPTH);

// FIFO Memory

// Storage array
reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];

// Read / Write Pointers
// Extra MSB used for full detection

reg [PTR_WIDTH:0] write_pointer;
reg [PTR_WIDTH:0] read_pointer;

// Write Logic

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        write_pointer <= 0;

    else if (cs && wr_en && !full)
    begin
        fifo[write_pointer[PTR_WIDTH-1:0]] <= data_in;
        write_pointer <= write_pointer + 1'b1;
    end
end

// Read Logic

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        read_pointer <= 0;
        data_out     <= {DATA_WIDTH{1'b0}};
    end

    else if (cs && rd_en && !empty)
    begin
        data_out     <= fifo[read_pointer[PTR_WIDTH-1:0]];
        read_pointer <= read_pointer + 1'b1;
    end
end

// Status Logic

// FIFO empty condition
assign empty = (write_pointer == read_pointer);

// FIFO full condition using extra MSB
assign full =
    (read_pointer ==
     {~write_pointer[PTR_WIDTH],
       write_pointer[PTR_WIDTH-1:0]});

// Occupancy count
assign fill_count = write_pointer - read_pointer;

// Almost flags
assign almost_full  = (fill_count >= ALMOST_FULL_THRESHOLD) && !full;
assign almost_empty = (fill_count <= ALMOST_EMPTY_THRESHOLD) && !empty;

endmodule