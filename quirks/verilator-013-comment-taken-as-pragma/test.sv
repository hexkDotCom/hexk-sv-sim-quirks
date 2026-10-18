// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-013: a comment that begins with the tool's name is read as a directive.
module top;
   initial begin
`ifndef QUIRK_NO_TRIGGER
      // Verilator users: this line is only a comment.
      $display("QUIRK_RESULT: AS_EXPECTED");
`endif
      // Users of that tool: this line is only a comment.
      $display("QUIRK_WORKAROUND: OK");
      $finish;
   end
endmodule
