require "nvchad.mappings"

-- stinky functions

-- Holy chatgpt
local uv     = vim.loop
local api    = vim.api
local fs     = vim.fs

-- files or dirs whose presence marks the project root
local markers = { ".git", "package.json", "Makefile", "CMakeLists.txt", "Cargo.toml" }

--- Look for markers in `dir`, returning true if any exist there.
local function has_marker(dir)
  for _, m in ipairs(markers) do
    if uv.fs_stat(dir .. "/" .. m) then
      return true
    end
  end
  return false
end

--- Walk upward (including the start directory) until a marker is found.
--- @param start string: path to a file or directory
--- @return string: the directory in which a marker was found, or cwd fallback
local function find_root_dir(start)
  -- normalize symlinks
  local path = uv.fs_realpath(start) or start
  -- if they gave us a file, reduce to its containing directory
  local stat = uv.fs_stat(path)
  if stat and stat.type == "file" then
    path = fs.dirname(path)
  end

  -- 1) check the start directory itself
  if has_marker(path) then
    return path
  end

  -- 2) walk each parent
  for dir in fs.parents(path) do
    if has_marker(dir) then
      return dir
    end
  end

  -- 3) nothing found → fall back
  return uv.fs_realpath(uv.cwd())
end

--- Return the project root for the current buffer.
--- @return string
local function project_root()
  local bufname = api.nvim_buf_get_name(0)
  local start = bufname ~= "" and bufname or uv.cwd()
  return find_root_dir(start)
end


local format = function()
  require("conform").format()
end

local map = vim.keymap.set

-- actual mappings

-- Code
map("n", "<leader>cf", format, { desc = "Format Buffer" })

-- Snacks
map("n", "<leader>e", function()
  require("snacks").explorer { cwd = project_root() }
end, { desc = "Explorer (root dir)" })

map("n", "<leader>E", function()
  require("snacks").explorer()
end, { desc = "Explorer (cwd)" })

map("n", "<leader>gg", function()
  require("snacks").lazygit()
end, { desc = "Lazygit" })

map("n", "<leader>ff", function()
  require("snacks").picker.pick("files", { cwd = project_root() })
end, { desc = "Find Files (root)" })

map("n", "<leader>fF", function()
  require("snacks").picker.pick("files", { cwd = vim.loop.cwd() })
end, { desc = "Find Files (cwd)" })
