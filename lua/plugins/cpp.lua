-- lua/custom/plugins.lua
return {
  -- Treesitter: ensure C-family parser is installed
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_deep_extend("force", opts.ensure_installed or {}, { "cpp" })
    end,
  },

  -- clangd-extensions: only load for C/C++/ObjC/CUDA/Proto when there's a compile db or clang* config
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    -- only load if we detect any of these in the project root:
    cond = function()
      return require("lspconfig.util").root_pattern(
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac"
      )(vim.fn.getcwd()) ~= nil
    end,
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      inlay_hints = { inline = false },
      ast = {
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
        },
      },
    },
    config = function(_, opts)
      -- merge with the lspconfig server opts below
      local lsp_opts = require("nvchad.configs.lspconfig").defaults().servers.clangd
      require("clangd_extensions").setup(vim.tbl_deep_extend("force", opts, { server = lsp_opts }))
    end,
  },

  -- Your LSP config is driven by nvchad.configs.lspconfig:
  -- here we just customize the clangd server options:
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          keys = {
            { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
              fname
            ) or require("lspconfig.util").find_git_ancestor(fname)
          end,
        },
      },
      -- no special `setup` needed here: clangd_extensions takes over
    },
  },

  -- DAP + codelldb for C/C++
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "codelldb" } },
      },
    },
    config = function()
      local dap = require "dap"
      -- register the codelldb adapter if not already present
      if not dap.adapters.codelldb then
        dap.adapters.codelldb = {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "codelldb",
            args = { "--port", "${port}" },
          },
        }
      end
      -- two launch configurations for C and C++
      for _, lang in ipairs { "c", "cpp" } do
        dap.configurations[lang] = {
          {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
          {
            name = "Attach to process",
            type = "codelldb",
            request = "attach",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
