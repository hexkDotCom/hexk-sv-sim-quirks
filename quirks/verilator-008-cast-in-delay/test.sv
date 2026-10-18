// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-008: a cast inside a delay expression is an internal error.
module top;
   timeunit 1ns; timeprecision 1ps;

   initial begin
      int unsigned steps = 3;
      realtime     start;
      time         amount;
`ifndef QUIRK_NO_TRIGGER
      start = $realtime;
      #(longint'(steps) * 1ns);
      if ($realtime - start == 3.0) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS waited %0.3f ns", $realtime - start);
`endif
      start  = $realtime;
      amount = longint'(steps);
      #(amount * 1ns);
      if ($realtime - start == 3.0) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS waited %0.3f ns", $realtime - start);
      $finish;
   end
endmodule
