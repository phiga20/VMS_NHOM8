//`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2024 04:07:10 AM
// Design Name: 
// Module Name: aes_128_ofb
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


module aes_128_ofb(
    input           clk,        // Clock
    input           rst_n,      // Reset
    input           ld,         // Load initialization vector (iv)
    input           mode,       // Mode select (0: Encrypt, 1: Decrypt)
    output          ofb_done,   // Done flag
    input  [127:0]  key,        // AES key
    input  [127:0]  iv,         // Initialization vector
    input  [127:0]  data_in,    // Input plaintext or ciphertext
    output [127:0]  data_out    // Output ciphertext or plaintext
);

    // Internal signals for encryption and decryption
    wire [127:0] enc_data_out;
    wire [127:0] dec_data_out;
    wire enc_done;
    wire dec_done;

    // Instantiate encrypt_ofb module
    encrypt_ofb enc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ld(ld && (mode == 0)),
        .enc_done(enc_done),
        .key(key),
        .iv(iv),
        .data_in(data_in),
        .data_out(enc_data_out)
    );

    // Instantiate decrypt_ofb module
    decrypt_ofb dec_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ld(ld && (mode == 1)),
        .dec_done(dec_done),
        .key(key),
        .iv(iv),
        .ct(data_in),
        .pt(dec_data_out)
    );

    // Output and done signals based on mode
    assign data_out = (mode == 0) ? enc_data_out : dec_data_out;
    assign ofb_done = (mode == 0) ? enc_done : dec_done;

endmodule

