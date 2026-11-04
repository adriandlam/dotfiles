-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- movement: on Alt so Ctrl+hjkl stays LazyVim's window navigation. These replace
-- LazyVim's Alt+j/k line moves in normal and visual mode.
vim.keymap.set({ "n", "v" }, "<M-k>", "<cmd>Treewalker Up<cr>", { silent = true, noremap = true })
vim.keymap.set({ "n", "v" }, "<M-j>", "<cmd>Treewalker Down<cr>", { silent = true, noremap = true })
vim.keymap.set({ "n", "v" }, "<M-h>", "<cmd>Treewalker Left<cr>", { silent = true, noremap = true })
vim.keymap.set({ "n", "v" }, "<M-l>", "<cmd>Treewalker Right<cr>", { silent = true, noremap = true })

-- swapping
vim.keymap.set("n", "<C-S-k>", "<cmd>Treewalker SwapUp<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-S-j>", "<cmd>Treewalker SwapDown<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-S-h>", "<cmd>Treewalker SwapLeft<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-S-l>", "<cmd>Treewalker SwapRight<cr>", { silent = true, noremap = true })
