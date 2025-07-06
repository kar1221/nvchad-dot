local supported_prettier = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "scss",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

local function has_config(ctx)
  vim.fn.system { "prettier", "--find-config-path", ctx.filename }
  return vim.v.shell_error == 0
end

local function has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype
  if vim.tbl_contains(supported_prettier, ft) then
    return true
  end
  local info = vim.fn.system { "prettier", "--file-info", ctx.filename }
  local ok, data = pcall(vim.fn.json_decode, info)
  return ok and data.inferredParser and data.inferredParser ~= vim.NIL
end

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    vue = { "prettier" },
    rust = { "rustfmt" },
    ["_"] = { "prettier" },
  },

  formatters = {
    prettier = {
      command = "prettier",
      args = { "--stdin-filepath", "$FILENAME" },
      condition = function(_, ctx)
        return has_parser(ctx) and has_config(ctx)
      end,
    },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
