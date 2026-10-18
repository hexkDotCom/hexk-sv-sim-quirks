// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk vcs-003: a covergroup method call inside ?: stops the compiler.
module top;
   class cov;
      bit enabled = 1;
      covergroup cg with function sample (bit [1:0] v);
         option.per_instance = 1;
         v_cp: coverpoint v;
      endgroup
      function new();
         cg = new();
      endfunction

`ifndef QUIRK_NO_TRIGGER
      function real coverage();
         return enabled ? cg.get_inst_coverage() : 0.0;
      endfunction
`endif

      function real coverage_if();
         if (enabled) return cg.get_inst_coverage();
         return 0.0;
      endfunction
   endclass

   initial begin
      cov c = new();
      c.cg.sample(2'd1);
`ifndef QUIRK_NO_TRIGGER
      if (c.coverage() == c.coverage_if()) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS %0.2f", c.coverage());
`endif
      if (c.coverage_if() >= 0.0) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS");
      $finish;
   end
endmodule
