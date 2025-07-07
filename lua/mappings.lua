require "nvchad.mappings"

local root = require("util.root").root

-- stinky functions

-- Holy chatgpt

-- files or dirs whose presence marks the project root

local format = function()
  require("conform").format()
end

local map = vim.keymap.set
local nomap = vim.keymap.del

-- actual mappings

nomap("n", "<leader>ch")

-- Code
map("n", "<leader>cf", format, { desc = "Format Buffer" })

-- Snacks
-- map("n", "<leader>e", function()
--   require("snacks").explorer { cwd = project_root() }
-- end, { desc = "Explorer (root dir)" })
--
-- map("n", "<leader>E", function()
--   require("snacks").explorer()
-- end, { desc = "Explorer (cwd)" })

map("n", "<leader>e", function()
  require("nvim-tree.api").tree.toggle { path = root() }
end, { desc = "Explorer" })

map("n", "<leader>E", function()
  require("nvim-tree.api").tree.toggle { path = vim.loop.cwd() }
end, { desc = "Explorer (cwd)" })

map("n", "<leader>gg", function()
  require("snacks").lazygit()
end, { desc = "Lazygit" })

-- map("n", "<leader>ff", function()
--   require("snacks").picker.pick("files", { cwd = project_root() })
-- end, { desc = "Find Files (root)" })
--
-- map("n", "<leader>fF", function()
--   require("snacks").picker.pick("files", { cwd = vim.loop.cwd() })
-- end, { desc = "Find Files (cwd)" })

map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
