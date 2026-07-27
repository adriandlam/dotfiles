-- Linear for Neovim.
--
-- A port of the Linear theme already running in Ghostty, bat, delta, lazygit
-- and Zed on this machine. See lua/linear/palette.lua for provenance.

local M = {}

---@class LinearOptions
local defaults = {
  -- Let the terminal background show through. Ghostty's Linear background is
  -- #17181d, identical to this theme's, so transparency looks the same as an
  -- opaque background — but keeps padding and blur consistent.
  transparent = true,
  ---@type "dark"|"light"|nil  nil follows vim.o.background
  variant = nil,
  italics = {
    comments = true,
    keywords = true,
    functions = false,
    strings = false,
    variables = false,
  },
  ---@type table<string, vim.api.keyset.highlight>
  overrides = {},
  ---@type fun(colors: table): table<string, vim.api.keyset.highlight>|nil
  on_highlights = nil,
}

M.options = vim.deepcopy(defaults)

---@param opts LinearOptions|nil
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

--- Resolve the palette for the active variant.
function M.colors()
  local palette = require("linear.palette")
  local variant = M.options.variant or (vim.o.background == "light" and "light" or "dark")
  return palette[variant] or palette.dark, variant
end

---@param opts LinearOptions|nil applied for this load only
function M.load(opts)
  if opts then
    M.setup(opts)
  end

  local colors, variant = M.colors()

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  vim.o.termguicolors = true
  vim.o.background = variant
  vim.g.colors_name = "linear"

  local highlights = require("linear.highlights")
  local groups = highlights.get(colors, M.options)

  -- User overrides, static then computed.
  for group, spec in pairs(M.options.overrides) do
    groups[group] = spec
  end
  if M.options.on_highlights then
    for group, spec in pairs(M.options.on_highlights(colors) or {}) do
      groups[group] = spec
    end
  end

  local set = vim.api.nvim_set_hl
  for group, spec in pairs(groups) do
    set(0, group, spec)
  end

  highlights.terminal(colors)
end

return M
