`timescale 1ns / 1ps

module uart_top #(
    parameter CLK_FREQ = 100_000,
    parameter BAUD_RATE = 9600
)(
    input wire clk, reset,
    input wire rx,
    input wire tx_start,
    input wire [7:0] tx_data,
    output wire tx,
    output wire [7:0] rx_data,
    output wire tx_done, rx_done
);

    wire tick;

    // 1. Instantiate Baud Rate Generator
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_unit (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // 2. Instantiate UART Receiver
    uart_rx rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(tick),
        .rx_done(rx_done),
        .dout(rx_data)
    );

    // 3. Instantiate UART Transmitter
    uart_tx tx_unit (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tick(tick),
        .din(tx_data),
        .tx_done(tx_done),
        .tx(tx)
    );

endmodule