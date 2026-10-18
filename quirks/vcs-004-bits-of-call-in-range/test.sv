// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk vcs-004: $bits of a function call in a declaration range is rejected when the function
// reads a variable outside itself.
module top;
   int offset = 4;

   function automatic int shifted(int v);
      return v + offset;
   endfunction

   typedef int result_t;

   initial begin
`ifndef QUIRK_NO_TRIGGER
      // $bits of an expression of a fixed-size type is a constant; the call is not evaluated.
      logic [$bits(shifted(0))-1:0] wide;
      if ($bits(wide) == 32) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS $bits %0d", $bits(wide));
`endif
      begin
         logic [$bits(result_t)-1:0] by_type;
         if ($bits(by_type) == 32) $display("QUIRK_WORKAROUND: OK");
         else $display("QUIRK_WORKAROUND: FAILS $bits %0d", $bits(by_type));
      end
      $finish;
   end
endmodule
