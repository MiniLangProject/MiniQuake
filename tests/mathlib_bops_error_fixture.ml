/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/mathlib_bops_error_fixture.ml.
*/
import miniquake.mathlib as mathPort

// Parse command-line arguments and run the selected operation.
function main(args)
  mathPort.BOPS_Error()
  return 0
end function
