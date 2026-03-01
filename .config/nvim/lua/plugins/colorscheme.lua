return {
  "datsfilipe/vesper.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("vesper").setup({
      transparent = true,
      italics = {
        comments = true,
        keywords = true,
        functions = false,
        strings = false,
        variables = false,
      },
      overrides = {
        -- Dashboard
        DashboardRecent = { fg = "#ffc799" },
        DashboardProject = { fg = "#a0a0a0" },
        DashboardConfiguration = { fg = "#ffffff" },
        DashboardSession = { fg = "#99ffe4" },
        DashboardLazy = { fg = "#99ffe4" },
        DashboardServer = { fg = "#ffc799" },
        DashboardQuit = { fg = "#ff8080" },

        -- Diagnostics
        DiagnosticUnnecessary = { link = "Comment" },

        -- Snacks Picker
        SnacksPicker = { bg = "NONE", fg = "#a0a0a0" },
        SnacksPickerBorder = { bg = "NONE", fg = "#505050" },
        SnacksPickerTree = { fg = "#505050" },
        SnacksPickerCol = { fg = "#505050" },

        -- UI elements
        NonText = { fg = "#505050" },
        FloatBorder = { fg = "#505050" },
        ColorColumn = { bg = "#1a1a1a" },
      },
    })
    vim.cmd.colorscheme("vesper")

    -- LSP comment overrides (applied after colorscheme loads)
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "vesper*",
      callback = function()
        vim.cmd([[hi @lsp.type.comment.c guifg=NONE]])
        vim.cmd([[hi @lsp.type.comment.cpp guifg=NONE]])
      end,
    })
  end,
}
