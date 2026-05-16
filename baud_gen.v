`timescale 1ns / 1ps

module baud_gen #(
    parameter CLK_FREQ = 100000000, 
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire reset,
    output wire tick
);

    
    localparam TICK_LIMIT = (BAUD_RATE == 0) ? 1 : (CLK_FREQ / (BAUD_RATE * 16));
    
   
    reg [$clog2(TICK_LIMIT)-1:0] count_reg;
    reg tick_reg;

    always @(posedge clk) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 1'b0;
        end else begin
            if (count_reg == (TICK_LIMIT - 1)) begin
                count_reg <= 0;
                tick_reg  <= 1'b1;
            end else begin
                count_reg <= count_reg + 1;
                tick_reg  <= 1'b0;
            end
        end
    end

    assign tick = tick_reg;

endmodule