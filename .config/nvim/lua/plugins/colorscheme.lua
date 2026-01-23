return {
  "loctvl842/monokai-pro.nvim",
  lazy = false,
  branch = "master",
  priority = 1000,
  config = function()
    require("monokai-pro").setup({
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
      override = function(scheme)
        return {
          colorcolumn = { bg = scheme.base.dimmed3 },
          dashboardrecent = { fg = scheme.base.magenta },
          dashboardproject = { fg = scheme.base.blue },
          dashboardconfiguration = { fg = scheme.base.white },
          dashboardsession = { fg = scheme.base.green },
          dashboardlazy = { fg = scheme.base.cyan },
          dashboardserver = { fg = scheme.base.yellow },
          dashboardquit = { fg = scheme.base.red },
          DiagnosticUnnecessary = { link = "Comment" },
          SnacksPicker = { bg = scheme.editor.background, fg = scheme.base.dimmed1 },
          SnacksPickerBorder = { bg = scheme.editor.background, fg = scheme.base.dimmed4 },
          SnacksPickerTree = { fg = scheme.base.dimmed3 },
          SnacksPickerCol = { fg = scheme.base.dimmed3 },
          NonText = { fg = scheme.base.dimmed3 },
          FloatBorder = { fg = scheme.base.dimmed4 },
        }
      end,
    })
    vim.cmd.colorscheme("monokai-pro")

    -- LSP comment overrides (applied after colorscheme loads)
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "monokai-pro*",
      callback = function()
        vim.cmd([[hi @lsp.type.comment.c guifg=NONE]])
        vim.cmd([[hi @lsp.type.comment.cpp guifg=NONE]])
      end,
    })
  end,
}
