//`timescale 1ns / 10ps
module encrypt_ofb(
    input           clk,        // Clock
    input           rst_n,        // Reset
    input           ld,         // Load initialization vector (iv)
    output          enc_done,   // Done flag
    input  [127:0]  key,        // AES key
    input  [127:0]  iv,         // Initialization vector
    input  [127:0]  data_in,    // Input plaintext
    output [127:0]  data_out    // Output ciphertext
);

    // Internal signals
    reg             ld_r;
    reg  [127:0]    iv_r;
    wire [127:0]    iv_out;
    wire            enc_done_w;

    // Instantiate aes_cipher_top for OFB mode
    iv_encrypt u1(
        .clk(clk),
        .rst_n(rst_n),
        .ld(ld),
        .done(enc_done_w),
        .key(key),
        .iv(iv),
        .iv_out(iv_out)
    );

    // Internal registers for OFB mode
    reg  [127:0]    data_out_reg;
    reg  [3:0]      dcnt;
    reg             done_reg;   // Internal register for done flag

    // Synchronize ld signal with clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ld_r <= 1'b0;
        end else begin
            ld_r <= ld;
        end
    end

    // Update IV register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            iv_r <= 128'h0;
        end else if (ld_r) begin
            iv_r <= iv;
        end else begin
            iv_r <= iv_out;
        end
    end

    // Update data_out register based on done_reg
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_reg <= 128'h0;
        end else if (done_reg) begin
            // Calculate data_out only when done_reg goes high
            data_out_reg <= data_out_reg;
        end
    end

    // Logic to set done_reg based on ld and dcnt
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dcnt <= 4'b0;
            done_reg <= 1'b0;
        end else begin
            if (!ld_r && (dcnt[3:0] == 4'b0001)) begin
                data_out_reg <= iv_out ^ data_in;
                done_reg <= 1'b1;
            end else begin
                done_reg <= 1'b0;
            end
            // Decrement dcnt
            if (ld_r) begin
                dcnt <= 4'b1011;
            end else if (|dcnt) begin
                dcnt <= dcnt - 1'b1;
            end else begin
                dcnt <= 4'b0;
            end
        end
    end

    // Assign outputs
    assign enc_done = done_reg;
    assign data_out = data_out_reg;

endmodule