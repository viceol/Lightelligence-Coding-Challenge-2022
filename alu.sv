module alu
  (

   input  clk,
   input  reset_n,

   input  alu_pkg::alu_cmd_t alu_cmd,
   input  alu_pkg::uint_vld_t operand_a,
   input  alu_pkg::uint_vld_t operand_b,

   output alu_pkg::uint_vld_t result

   );

  alu_pkg::uint_t accum, next_accum, 
         add_out, sub_out, mul_out, div_out, div_rem;

  add addition(.a(operand_a.data),
               .b(operand_b.data),
               .out(add_out));

  sub subtraction(.a(operand_a.data),
                  .b(operand_b.data),
                  .out(add_out));

  mul multiplication(.a(operand_a.data),
                     .b(operand_b.data),
                     .out(add_out));

  div division(.a(operand_a.data),
               .b(operand_b.data),
               .out(add_out),
               .remainder(div_rem));

  always_comb begin
    result.vld = operand_a.vld & operand_b.vld & alu_cmd.vld; // Result is only valid if both inputs are valid and the command is valid
    case (alu_cmd.opcode)
      alu_pkg::ADD: result.data = add_out;
      alu_pkg::SUB: result.data = sub_out;
      alu_pkg::MUL: result.data = mul_out;
      alu_pkg::DIV: result.data = div_out;
      alu_pkg::MUL_ACCUM: begin
        result.data = accum + mul_out;  // Assuming MAC operation outputs new accum register value
        next_accum = accum + mul_out;
      end
      default: result.vld = 0; // Assuming that undefined operations are invalid
    endcase
  end

  always_ff @(posedge clk) begin // Accumulator register
    if (reset_n) begin
      accum <= 0;
    end else begin
      accum <= next_accum;
    end
  end

endmodule
