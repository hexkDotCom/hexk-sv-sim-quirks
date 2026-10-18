// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-010: a virtual interface cannot be assigned null.
interface quirk_if;
   logic sig;
endinterface

module top;
   quirk_if bus ();

   class user;
      virtual quirk_if vif;
      bit has_vif;

      function void connect(virtual quirk_if v);
         vif = v;
         has_vif = 1;
      endfunction

`ifndef QUIRK_NO_TRIGGER
      function void disconnect();
         vif = null;
      endfunction
`endif

      function void disconnect_flag();
         has_vif = 0;
      endfunction
   endclass

   initial begin
      user u = new();
      u.connect(bus);
`ifndef QUIRK_NO_TRIGGER
      u.disconnect();
      if (u.vif == null) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS vif is not null");
`endif
      u.connect(bus);
      u.disconnect_flag();
      if (!u.has_vif) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS");
      $finish;
   end
endmodule
