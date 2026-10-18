// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk diff-001: an override of a virtual method with other argument names.
// IEEE 1800 requires identical argument names, so the trigger is illegal code.
module top;
   class base;
      virtual function int scale(int value);
         return value;
      endfunction
   endclass

   class derived extends base;
`ifndef QUIRK_NO_TRIGGER
      virtual function int scale(int amount);
         return 2 * amount;
      endfunction
`else
      virtual function int scale(int value);
         return 2 * value;
      endfunction
`endif
   endclass

   initial begin
      derived d = new();
      base    b = d;
`ifndef QUIRK_NO_TRIGGER
      $display("QUIRK_RESULT: DIFFERS the override with another argument name was accepted");
`endif
      if (b.scale(3) == 6) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS");
      $finish;
   end
endmodule
