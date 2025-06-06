`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2025 09:25:04 PM
// Design Name: 
// Module Name: uart_protocol
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    output reg   tx,
    output reg   tx_busy,
    output reg   tx_done
);

    parameter CLKS_PER_BIT = 5208;

    reg [12:0] clk_cnt = 0;
    reg [3:0]  bit_idx = 0;
    reg [9:0]  tx_shift = 10'b1111111111;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1;
            tx_busy <= 0;
            tx_done <= 0;
            clk_cnt <= 0;
            bit_idx <= 0;
        end else begin
            tx_done <= 0;  // Default value

            if (tx_start && !tx_busy) begin
                tx_busy <= 1;
                tx_shift <= {1'b1, tx_data, 1'b0};  // stop, data, start
                clk_cnt <= 0;
                bit_idx <= 0;
                tx <= 0;  // Start bit immediately
            end else if (tx_busy) begin
                if (clk_cnt < CLKS_PER_BIT - 1) begin
                    clk_cnt <= clk_cnt + 1;
                end else begin
                    clk_cnt <= 0;
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == 9) begin
                        tx_busy <= 0;
                        tx_done <= 1;
                        tx <= 1;  // Line idle after stop bit
                    end else begin
                        tx <= tx_shift[bit_idx + 1];  // Shift out next bit
                    end
                end
            end
        end
    end
endmodule

module uart_rx (
    input        clk,
    input        rst,
    input        rx,
    output reg [7:0] rx_data,
    output reg      rx_done
);

    parameter CLKS_PER_BIT = 5208;

    reg [3:0]  state = 0;
    reg [12:0] clk_cnt = 0;
    reg [3:0]  bit_idx = 0;
    reg [7:0]  rx_shift = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            clk_cnt <= 0;
            bit_idx <= 0;
            rx_done <= 0;
            rx_data <= 0;
        end else begin
            rx_done <= 0;  // Default value

            case (state)
                0: begin // IDLE
                    if (~rx) begin
                        state <= 1;
                        clk_cnt <= 0;
                    end
                end

                1: begin // START BIT
                    if (clk_cnt == (CLKS_PER_BIT/2)) begin
                        if (~rx) begin
                            clk_cnt <= 0;
                            bit_idx <= 0;
                            state <= 2;
                        end else begin
                            state <= 0;  // False start bit
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                2: begin // DATA BITS
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        rx_shift[bit_idx] <= rx;
                        if (bit_idx == 7) begin
                            state <= 3;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end

                3: begin // STOP BIT
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        state <= 0;
                        rx_data <= rx_shift;
                        rx_done <= 1;
                        clk_cnt <= 0;
                    end
                end
            endcase
        end
    end
endmodule


