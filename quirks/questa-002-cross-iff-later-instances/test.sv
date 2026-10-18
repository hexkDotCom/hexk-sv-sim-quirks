// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk questa-002: a cross with iff is counted wrong from the second covergroup instance on.
module top;
   typedef enum {S_IDLE, S_WAIT, S_STALL, S_ACTIVE} state_e;

`ifndef QUIRK_NO_TRIGGER
   class pair_cov;
      covergroup cg with function sample (state_e state, state_e prior, bit has_prior);
         option.per_instance = 1;
         option.get_inst_coverage = 1;
         state_cp: coverpoint state;
         prior_cp: coverpoint prior iff (has_prior) {option.weight = 0;}
         pair_x: cross prior_cp, state_cp iff (has_prior);
      endgroup
      function new();
         cg = new();
      endfunction
   endclass

   // Four samples, none with a cycle before: the cross must stay at 0.
   function automatic real run_iff();
      pair_cov c = new();
      for (int i = 0; i < 4; i++) c.cg.sample(state_e'(i), S_IDLE, 0);
      return c.cg.pair_x.get_inst_coverage();
   endfunction
`endif

   // Pairs in a covergroup of their own, sampled only when there is a cycle before.
   class split_cov;
      covergroup state_cg with function sample (state_e state);
         option.per_instance = 1;
         option.get_inst_coverage = 1;
         state_cp: coverpoint state;
      endgroup
      covergroup pair_cg with function sample (state_e state, state_e prior);
         option.per_instance = 1;
         option.get_inst_coverage = 1;
         state_cp: coverpoint state {option.weight = 0;}
         prior_cp: coverpoint prior {option.weight = 0;}
         pair_x: cross prior_cp, state_cp;
      endgroup
      function new();
         state_cg = new();
         pair_cg  = new();
      endfunction
   endclass

   function automatic real run_split();
      split_cov c = new();
      for (int i = 0; i < 4; i++) c.state_cg.sample(state_e'(i));
      return c.pair_cg.pair_x.get_inst_coverage();
   endfunction

   initial begin
      real a, b, c;
`ifndef QUIRK_NO_TRIGGER
      a = run_iff();
      b = run_iff();
      c = run_iff();
      if (a == 0.0 && b == 0.0 && c == 0.0) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS cross coverage %0.2f %0.2f %0.2f (want 0)", a, b, c);
`endif
      a = run_split();
      b = run_split();
      c = run_split();
      if (a == 0.0 && b == 0.0 && c == 0.0) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS %0.2f %0.2f %0.2f", a, b, c);
      $finish;
   end
endmodule
