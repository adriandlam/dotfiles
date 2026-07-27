-- Linear is a local colorscheme, not a plugin: it lives in
-- ~/.config/nvim/lua/linear/ with the entry point at colors/linear.lua.
-- It matches the Ghostty, bat, delta, lazygit and Zed themes on this machine.

return {
  -- Configure Linear before LazyVim applies the colorscheme.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("linear").setup({
          transparent = true,
          italics = {
            comments = true,
            keywords = true,
            functions = false,
            strings = false,
            variables = false,
          },
        })
        vim.cmd.colorscheme("linear")
      end,
    },
  },

  -- Kept installed but not loaded, so `:colorscheme vesper` still works.
  {
    "datsfilipe/vesper.nvim",
    lazy = true,
    opts = {
      transparent = true,
      italics = { comments = true, keywords = true },
    },
  },
}
