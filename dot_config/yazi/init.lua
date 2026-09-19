require("full-border"):setup { type = ui.Border.PLAIN }
require("no-status"):setup()

-- Remaining plugins are invoked through keymap bindings. They export
-- only `entry` (no `setup()` function), so a bare require is enough to
-- have them loaded at startup. NOTE: do NOT call `:setup()` on them.
-- (smart-enter's `setup()` requires an opts table and errors without one;
-- defaults are used unless explicitly configured.)
require("diff")
require("smart-enter")
require("smart-filter")
require("smart-paste")
require("jump-to-char")
