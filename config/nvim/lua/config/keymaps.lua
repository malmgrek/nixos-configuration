local map = vim.keymap.set

-- Match Doom muscle memory
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Switch project" })
map("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "Switch buffer" })
map("n", "<leader>ss", "<cmd>Telescope live_grep<cr>", { desc = "Search in project" })
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })

-- Window management (Doom-like)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
