`timescale 1ns / 1ns

module tb_fifo_sync();

/////////////////////////////////////////////////////
// Testbench parameters
/////////////////////////////////////////////////////

parameter FIFO_DEPTH = 8;
parameter DATA_WIDTH = 32;

reg clk = 0;
reg rst_n;
reg cs;
reg wr_en;
reg rd_en;
reg [DATA_WIDTH-1:0] data_in;

wire [DATA_WIDTH-1:0] data_out;
wire empty;
wire full;
wire almost_full;
wire almost_empty;

wire [$clog2(FIFO_DEPTH):0] fill_count;

integer i;

/////////////////////////////////////////////////////
// Instantiate DUT
/////////////////////////////////////////////////////

fifo_sync
#(
    .FIFO_DEPTH(FIFO_DEPTH),
    .DATA_WIDTH(DATA_WIDTH)
)
dut
(
    .clk(clk),
    .rst_n(rst_n),
    .cs(cs),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .empty(empty),
    .full(full),
    .almost_full(almost_full),
    .almost_empty(almost_empty),
    .fill_count(fill_count)
);

/////////////////////////////////////////////////////
// Clock generation
/////////////////////////////////////////////////////

always #5 clk = ~clk;

/////////////////////////////////////////////////////
// Write Task
/////////////////////////////////////////////////////

task write_data(input [DATA_WIDTH-1:0] d_in);
begin
    @(posedge clk);

    cs      = 1;
    wr_en   = 1;
    data_in = d_in;

    @(posedge clk);

    $display("Time=%0t WRITE data=%0d fill=%0d AF=%0b FULL=%0b",
              $time, d_in, fill_count, almost_full, full);

    wr_en = 0;
end
endtask

/////////////////////////////////////////////////////
// Read Task
/////////////////////////////////////////////////////

task read_data();
begin
    @(posedge clk);

    cs    = 1;
    rd_en = 1;

    @(posedge clk);

    $display("Time=%0t READ  data=%0d fill=%0d AE=%0b EMPTY=%0b",
              $time, data_out, fill_count, almost_empty, empty);

    rd_en = 0;
end
endtask

/////////////////////////////////////////////////////
// Stimulus
/////////////////////////////////////////////////////

initial
begin

    rst_n = 0;
    rd_en = 0;
    wr_en = 0;
    cs    = 0;
    data_in = 0;

    #20;
    rst_n = 1;

/////////////////////////////////////////////////////
// SCENARIO 1 : Basic FIFO
/////////////////////////////////////////////////////

$display("\n---- SCENARIO 1 : Basic FIFO ----");

write_data(1);
write_data(10);
write_data(100);

read_data();
read_data();
read_data();

/////////////////////////////////////////////////////
// SCENARIO 2 : Fill FIFO
/////////////////////////////////////////////////////

$display("\n---- SCENARIO 2 : Fill FIFO ----");

for (i = 0; i < FIFO_DEPTH; i = i + 1)
begin
    write_data(i);
end

/////////////////////////////////////////////////////
// SCENARIO 3 : Drain FIFO
/////////////////////////////////////////////////////

$display("\n---- SCENARIO 3 : Drain FIFO ----");

for (i = 0; i < FIFO_DEPTH; i = i + 1)
begin
    read_data();
end

/////////////////////////////////////////////////////
// SCENARIO 4 : Almost Full Test
/////////////////////////////////////////////////////

$display("\n---- SCENARIO 4 : Almost Full ----");

for (i = 0; i < FIFO_DEPTH-2; i = i + 1)
begin
    write_data(i+50);
end

/////////////////////////////////////////////////////
// SCENARIO 5 : Almost Empty Test
/////////////////////////////////////////////////////

$display("\n---- SCENARIO 5 : Almost Empty ----");

for (i = 0; i < FIFO_DEPTH-3; i = i + 1)
begin
    read_data();
end

/////////////////////////////////////////////////////

#50;
$finish;

end

/////////////////////////////////////////////////////
// Waveform dump
/////////////////////////////////////////////////////

initial
begin
    $dumpfile("fifo_wave.vcd");
    $dumpvars(0,tb_fifo_sync);
end

endmodule