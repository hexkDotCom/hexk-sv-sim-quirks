// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-007: no enum methods for an enum wider than 64 bits.
module top;
`ifndef QUIRK_NO_TRIGGER
   typedef enum logic [79:0] {
      WIDE_A = 80'h1,
      WIDE_B = 80'h2
   } wide_e;
`endif
   typedef enum logic [63:0] {
      NARROW_A = 64'h1,
      NARROW_B = 64'h8000_0000_0000_0000
   } narrow_e;

   initial begin
`ifndef QUIRK_NO_TRIGGER
      wide_e w = WIDE_B;
      if (w.name() == "WIDE_B" && w.prev() == WIDE_A) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS name '%s'", w.name());
`endif
      begin
         narrow_e n = NARROW_B;
         if (n.name() == "NARROW_B" && n.prev() == NARROW_A) $display("QUIRK_WORKAROUND: OK");
         else $display("QUIRK_WORKAROUND: FAILS name '%s'", n.name());
      end
      $finish;
   end
endmodule
