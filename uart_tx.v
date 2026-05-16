module uart_tx (
    input wire clk, reset,
    input wire tx_start, tick,
    input wire [7:0] din,
    output reg tx_done,
    output reg tx
);

  
    localparam idle  = 2'b00;
    localparam start = 2'b01;
    localparam data  = 2'b10;
    localparam stop  = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next; // Ticks counter (0-15)
    reg [2:0] n_reg, n_next; // Bits counter (0-7)
    reg [7:0] b_reg, b_next; // Data buffer
    reg tx_next;

    // Sequential Block 
    always @(posedge clk) begin
        if (reset) begin
            state_reg <= idle;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
            tx        <= 1'b1; // Drive line HIGH during reset
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
            tx        <= tx_next; 
        end
    end

    // Combinational Block (Next-State & Output Logic)
    always @* begin
        state_next = state_reg;
        s_next     = s_reg;
        n_next     = n_reg;
        b_next     = b_reg;
        tx_next    = tx; 
        tx_done    = 1'b0;

        case (state_reg)
            idle: begin
                tx_next = 1'b1; // Default idle state for UART is HIGH
                if (tx_start) begin
                    state_next = start;
                    s_next     = 0;
                    b_next     = din;
                end
            end
            
            start: begin
                tx_next = 1'b0; // Start bit is always LOW
                if (tick) begin
                    if (s_reg == 15) begin
                        state_next = data;
                        s_next     = 0;
                        n_next     = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            data: begin
                tx_next = b_reg[0]; // Send Least Significant Bit (LSB) first
                if (tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1; //
                        if (n_reg == 7) begin
                            state_next = stop;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            stop: begin
                tx_next = 1'b1; // Stop bit is always HIGH
                if (tick) begin
                    if (s_reg == 15) begin
                        state_next = idle;
                        tx_done    = 1'b1; // 
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            default: state_next = idle;
        endcase
    end

endmodule