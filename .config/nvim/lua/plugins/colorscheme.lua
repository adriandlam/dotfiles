-- Linear, matching the Ghostty, bat, delta, lazygit and Zed themes on this
-- machine. Source: github.com/adriandlam/linear-nvim

return {
  {
    "adriandlam/linear-nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Ghostty already paints the Linear background, so letting it through
      -- keeps padding and blur consistent. The plugin defaults this off.
      transparent = true,
    },
    config = function(_, opts)
      require("linear").setup(opts)
    end,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "linear" } },

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
