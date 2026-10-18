// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk vcs-002: a string method called on a string parameter of a class is not implemented.
module top;
   class named #(string NAME = "abc");
`ifndef QUIRK_NO_TRIGGER
      function int name_length();
         return NAME.len();
      endfunction
`endif

      function int name_length_copy();
         string text = NAME;
         return text.len();
      endfunction
   endclass

   initial begin
      named #("hello") n = new();
`ifndef QUIRK_NO_TRIGGER
      if (n.name_length() == 5) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS length %0d", n.name_length());
`endif
      if (n.name_length_copy() == 5) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS length %0d", n.name_length_copy());
      $finish;
   end
endmodule
