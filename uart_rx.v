module uart_rx (
    input wire clk, reset,
    input wire rx, tick,
    output reg rx_done,
    output wire [7:0] dout
);

    localparam idle  = 2'b00;
    localparam start = 2'b01;
    localparam data  = 2'b10;
    localparam stop  = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;

    // Sequential Block 
    always @(posedge clk) begin
        if (reset) begin
            state_reg <= idle;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
        end
    end

    // Combinational Block 
    always @* begin
        state_next = state_reg;
        s_next     = s_reg;
        n_next     = n_reg;
        b_next     = b_reg;
        rx_done    = 1'b0;

        case (state_reg)
            idle: begin
                if (~rx) begin
                    state_next = start;
                    s_next     = 0;
                end
            end
            
            start: begin
                if (tick) begin
                    if (s_reg == 7) begin
                        state_next = data;
                        s_next     = 0;
                        n_next     = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            data: begin
                if (tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = {rx, b_reg[7:1]};
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
                if (tick) begin
                    if (s_reg == 15) begin
                        state_next = idle;
                        rx_done    = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            default: state_next = idle;
        endcase
    end

    assign dout = b_reg;

endmodule