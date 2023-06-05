`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 08:23:33 PM
// Design Name: 
// Module Name: random_number_generator
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


module random_number_generator(
    input   clk,
    output  logic [31:0]    Q
    );

logic [3:0] random_number = 1;

always_ff @ (posedge clk)
begin
    random_number[0] <= random_number[3];
    random_number[1] <= ( random_number[0] ^ random_number[3] );
    random_number[2] <= random_number[1];
    random_number[3] <= random_number[2];
end

always_comb
begin
    if( random_number > 0 )
        Q = 32'hFFFFFFFF;
    else
        Q = 0;
end

endmodule
