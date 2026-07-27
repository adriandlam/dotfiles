-- Linear palette.
--
-- Ported from the theme already used across this machine: the Ghostty theme in
-- .config/ghostty/themes/linear-dark, the bat/Sublime theme in
-- .config/bat/themes/Linear.tmTheme, the delta block in .gitconfig, and
-- github.com/adriandlam/zed-linear. Where bat and Zed disagreed, Zed won —
-- it carries UI colors the terminal themes have no concept of.
--
-- Keep these in sync when the upstream themes change.

local M = {}

M.dark = {
  -- Surfaces, darkest to lightest
  bg_deepest = "#080a0f", -- statusline, ghostty palette 0
  bg_panel = "#0a0c11", -- sidebars, file tree
  bg_dark = "#0f1219", -- inactive tabs
  bg_editor = "#12151d", -- Zed's editor background
  bg = "#17181d", -- Ghostty background; the canonical surface
  bg_hover = "#1f2330",
  bg_visual = "#22273a", -- selection
  bg_search = "#2a3050",

  border = "#252936",
  border_soft = "#1e2330",

  -- Text
  fg = "#e6e9ef",
  fg_bright = "#f7f8f8",
  fg_dim = "#d8dce6",
  fg_muted = "#b5bccb", -- operators, punctuation, hints
  fg_comment = "#636b7b", -- comments, line numbers, ignored

  -- Accents
  red = "#ff7e78",
  red_bright = "#ff9a95",
  green = "#69c967",
  teal = "#7ad9c0", -- strings
  teal_bright = "#95ead5",
  yellow = "#f5c56a", -- numbers, constants
  yellow_bright = "#ffd889",
  blue = "#73b7ff", -- types, classes, tags
  indigo = "#8c97ff", -- keywords; the Linear accent
  purple = "#c2a1ff", -- functions
  purple_bright = "#d4bdff",

  -- Diff backgrounds, lifted from the delta config so :Gdiff and `git diff`
  -- read the same.
  diff_add_bg = "#143023",
  diff_add_emph = "#1f4a32",
  diff_del_bg = "#3a1d20",
  diff_del_emph = "#52292c",
  diff_change_bg = "#252936",

  none = "NONE",
}

M.light = {
  bg_deepest = "#e8ecf5",
  bg_panel = "#eef1f7",
  bg_dark = "#eef1f7",
  bg_editor = "#f7f8fa",
  bg = "#f7f8fa",
  bg_hover = "#e8ecf5",
  bg_visual = "#e8ecf5",
  bg_search = "#dfe6f7",

  border = "#d3d9e6",
  border_soft = "#e2e7f0",

  fg = "#2a3140",
  fg_bright = "#1f2430",
  fg_dim = "#3a4152",
  fg_muted = "#6f7788",
  fg_comment = "#8a93a6",

  red = "#c94446",
  red_bright = "#d75a5c",
  green = "#52a450",
  teal = "#0f8f83",
  teal_bright = "#20a398",
  yellow = "#b4831f",
  yellow_bright = "#c9962f",
  blue = "#4380d8",
  indigo = "#5e6ad2",
  purple = "#8160d8",
  purple_bright = "#9476e0",

  diff_add_bg = "#dcf0e4",
  diff_add_emph = "#c2e5d0",
  diff_del_bg = "#fadcdd",
  diff_del_emph = "#f4c3c5",
  diff_change_bg = "#e2e7f0",

  none = "NONE",
}

return M
