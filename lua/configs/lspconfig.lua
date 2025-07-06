require("nvchad.configs.lspconfig").defaults()

local data_path = vim.fn.stdpath "data"
local vue_lsp_pkg = "mason/packages/vue-language-server/node_modules/@vue/language-server"
local vue_ls_path = data_path .. "/" .. vue_lsp_pkg

local vue_ts_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_ls_path,
  languages = { "vue" },
  configNamespace = "typescript",
  enableForWorkspaceTypeScriptVersions = true,
}

local function tailwind_root(fname)
  local fp = (type(fname) == "number") and vim.api.nvim_buf_get_name(fname) or fname

  -- 2) look for package.json upward from fp
  local pkg_files = vim.fs.find("package.json", { path = fp, upward = true })
  local pkg_path = pkg_files and pkg_files[1]
  if not pkg_path then
    return nil
  end

  -- 3) read package.json safely
  local ok, lines = pcall(vim.fn.readfile, pkg_path)
  if not ok then
    return nil
  end
  local content = table.concat(lines, "\n")

  -- 4) check for tailwindcss or @nuxt/ui
  if content:match [["tailwindcss"%s*:]] or content:match [["@nuxt/ui"%s*:]] then
    return vim.fs.dirname(pkg_path)
  end

  return nil
end

local servers = {
  "clangd",
  "cmake",
  "cssls",
  "css_modules_ls",
  "css_variables",
  "emmet_ls",
  "html",
  "jsonls",
  "lua_ls",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "vtsls",
  "vue_ls",
}

vim.lsp.config("cssls", {
  settings = {
    css = { lint = { unknownAtRules = "ignore" } },
  },
})

vim.lsp.config("tailwindcss", {
  root_dir = tailwind_root,
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
        },
      },
    },
  },
})

vim.lsp.config("vue_ls", {
  on_init = function(client)
    client.handlers["tsserver/request"] = function(_, result, context)
      local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = "vtsls" }
      if #clients == 0 then
        vim.notify("Could not found `vtsls` lsp client, vue_lsp would not work without it.", vim.log.levels.ERROR)
        return
      end
      local ts_client = clients[1]

      local param = unpack(result)
      local id, command, payload = unpack(param)
      ts_client:exec_cmd({
        title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
        command = "typescript.tsserverRequest",
        arguments = {
          command,
          payload,
        },
      }, { bufnr = context.bufnr }, function(_, r)
        local response_data = { { id, r.body } }
        ---@diagnostic disable-next-line: param-type-mismatch
        client:notify("tsserver/response", response_data)
      end)
    end
  end,
})

vim.lsp.config("vtsls", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = { vue_ts_plugin },
      },
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    complete_function_calls = true,
  },
})

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
