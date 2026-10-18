// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk questa-001: $time in a type-parameterized class uses the time unit of the package
// that specializes it with a type that package declares.
package lib_pkg;
   timeunit 1ps; timeprecision 1ps;

   // Returns the time in ps, the time unit of this package.
   class clock_reader #(type T = int);
      function longint unsigned now();
         return $time;
      endfunction
   endclass

   // The same through a class without a type parameter.
   class time_util;
      static function longint unsigned now_ps();
         return $time;
      endfunction
   endclass

   class safe_reader #(type T = int);
      function longint unsigned now();
         return time_util::now_ps();
      endfunction
   endclass
endpackage

package user_pkg;
   timeunit 1ns; timeprecision 1ps;

   class item;
      int data;
   endclass

`ifndef QUIRK_NO_TRIGGER
   class item_reader extends lib_pkg::clock_reader #(item);
   endclass
`endif

   class item_safe_reader extends lib_pkg::safe_reader #(item);
   endclass
endpackage

module top;
   timeunit 1ns; timeprecision 1ps;
   import user_pkg::*;

   initial begin
`ifndef QUIRK_NO_TRIGGER
      item_reader r = new();
`endif
      item_safe_reader s = new();
      #295ns;
`ifndef QUIRK_NO_TRIGGER
      if (r.now() == 295000) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS read %0d at 295 ns (want 295000 ps)", r.now());
`endif
      if (s.now() == 295000) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS read %0d", s.now());
      $finish;
   end
endmodule
