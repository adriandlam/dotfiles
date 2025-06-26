return {
  "loctvl842/monokai-pro.nvim",
  lazy = false,
  branch = "master",
  priority = 1000,
  config = function()
    local monokai = require("monokai-pro")
    monokai.setup({
      transparent_background = true,
      devicons = true,
      filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
      inc_search = "background", -- underline | background
      -- background_clear = {
      -- 	"float_win",
      -- 	"toggleterm",
      -- 	"telescope",
      -- 	-- "which-key",
      -- 	"renamer",
      -- 	"notify",
      -- 	"nvim-tree",
      -- 	"neo-tree",
      -- 	-- "bufferline", -- better used if background of `neo-tree` or `nvim-tree` is cleared
      -- },
      plugins = {
        bufferline = {
          underline_selected = true,
          underline_visible = false,
          bold = true,
        },
        indent_blankline = {
          context_highlight = "pro", -- default | pro
          context_start_underline = true,
        },
      },
      override = function(c)
        vim.cmd([[hi @lsp.type.comment.c guifg=NONE]]) -- just for now
        vim.cmd([[hi @lsp.type.comment.cpp guifg=NONE]]) -- just for now
        local hp = require("monokai-pro.color_helper")
        local common_fg = hp.lighten(c.sideBar.foreground, 30)
        return {
          colorcolumn = { bg = c.base.dimmed3 },
          dashboardrecent = { fg = c.base.magenta },
          dashboardproject = { fg = c.base.blue },
          dashboardconfiguration = { fg = c.base.white },
          dashboardsession = { fg = c.base.green },
          dashboardlazy = { fg = c.base.cyan },
          dashboardserver = { fg = c.base.yellow },
          dashboardquit = { fg = c.base.red },
          -- DiagnosticUnderlineError = { undercurl = false, underline = true },
          -- DiagnosticUnderlineWarn = { undercurl = false, underline = true },
          -- DiagnosticUnderlineInfo = { undercurl = false, underline = true },
          -- DiagnosticUnderlineHint = { undercurl = false, underline = true },
          -- DiagnosticUnnecessary = { undercurl = false, underline = true },
          DiagnosticUnnecessary = { link = "Comment" },
          SnacksPicker = { bg = c.editor.background, fg = common_fg },
          SnacksPickerBorder = { bg = c.editor.background, fg = c.tab.unfocusedActiveBorder },
          SnacksPickerTree = { fg = c.editorLineNumber.foreground },
          SnacksPickerCol = { fg = c.editorLineNumber.foreground },
          NonText = { fg = c.base.dimmed3 }, -- not sure if this should be broken into all hl groups importing NonText
          FloatBorder = { fg = c.tab.unfocusedActiveBorder },
          -- NormalFloat = { bg = c.editorSuggestWidget.background },
        }
      end,
    })
    monokai.load()
  end,
}
