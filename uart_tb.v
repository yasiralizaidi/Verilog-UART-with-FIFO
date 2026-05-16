`timescale 1ns / 1ps

module tb_uart;

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    wire rx; 

    wire tx;
    wire [7:0] rx_data;
    wire tx_done;
    wire rx_done;

    
    uart_top #(
        .CLK_FREQ(100000000),
        .BAUD_RATE(1152000) // Fast baud rate to minimize simulation wait time
    ) uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),          
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),          
        .rx_data(rx_data),
        .tx_done(tx_done),
        .rx_done(rx_done)
    );

    // Direct Loopback connection
    assign rx = tx;

    // 100MHz clock generation (20ns period)
    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;

        #100;
        reset = 0;
        #50;
        
        // Send letter 'A'
        $display("[TB] Sending Byte: 8'h41 ('A')");
        tx_data = 8'h41;
        tx_start = 1;
        #10;
        tx_start = 0; 

        fork
            wait(tx_done == 1'b1);
            wait(rx_done == 1'b1);
        join
        
        #20; 
        if (rx_data == 8'h41) begin
            $display("[TB] SUCCESS! Received matching data 8'h41");
        end else begin
            $display("[TB] ERROR: Data mismatch.");
        end

        #200;
        $finish;
    end
      
endmodule