`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2025 09:29:01 PM
// Design Name: 
// Module Name: top
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

module uart_top (
    input        clk,
    input        rst
);

    wire        tx_start;
    wire [7:0]  tx_data;
    wire        tx_busy;
    wire        rx_done;
    wire [7:0]  rx_data;
    wire        tx;
    wire        rx;

    // UART transmitter
    uart_tx #(.CLKS_PER_BIT(5208)) tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // UART receiver (loopback)
    uart_rx #(.CLKS_PER_BIT(5208)) rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx),            // Loopback tx to rx
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // VIO Instance (auto-generated ports)
    vio_0 vio_inst (
        .clk(clk),
        .probe_out0(tx_start),
        .probe_out1(tx_data),
        .probe_in0(tx_busy),
        .probe_in1(rx_done),
        .probe_in2(rx_data)
    );

    // ILA Instance
    ila_0 ila_inst (
        .clk(clk),
        .probe0(tx_start),
        .probe1(tx_data),
        .probe2(tx),
        .probe3(tx_busy),
        .probe4(rx),
        .probe5(rx_data),
        .probe6(rx_done)
    );

endmodule
