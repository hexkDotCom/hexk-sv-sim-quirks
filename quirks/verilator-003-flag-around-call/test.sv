// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-003: a member set before a call and cleared after it reads 0 inside the call.
package quirk_pkg;
   virtual class listener;
      pure virtual function void notify();
   endclass

   listener registered[$];

   function automatic void notify_all();
      foreach (registered[i]) registered[i].notify();
   endfunction

   class flagged extends listener;
      local bit busy;
      int seen = -1;

      virtual function void notify();
         seen = int'(busy);
      endfunction

      // Sets busy around a call that reaches notify().
      function void run();
         busy = 1;
         if (registered.size() != 0) notify_all();
         busy = 0;
      endfunction
   endclass

   class counted extends listener;
      local int unsigned depth;
      int seen = -1;

      virtual function void notify();
         seen = int'(depth != 0);
      endfunction

      // The state passed as a count that the call cannot see cleared.
      function void run();
         depth++;
         if (registered.size() != 0) notify_all();
         depth--;
      endfunction
   endclass
endpackage

module top;
   import quirk_pkg::*;
   initial begin
`ifndef QUIRK_NO_TRIGGER
      flagged f = new();
`endif
      counted c = new();
`ifndef QUIRK_NO_TRIGGER
      registered.push_back(f);
      f.run();
      if (f.seen == 1) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS busy read %0d inside the call", f.seen);
      registered.delete();
`endif
      registered.push_back(c);
      c.run();
      if (c.seen == 1) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS depth read %0d inside the call", c.seen);
      $finish;
   end
endmodule
