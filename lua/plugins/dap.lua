-- lua/custom/dap_config.lua
return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    recommended = true,
    desc = "Debugging support. Requires language‑specific adapters to be configured.",

    dependencies = {
      "rcarriga/nvim-dap-ui",
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      {
        "williamboman/mason.nvim",
        opts = { ensure_installed = { "codelldb" } },
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
      },
      "nvim-lua/plenary.nvim",
    },

    keys = {
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Run/Continue",
      },
      {
        "<leader>da",
        function()
          require("dap").continue { before = get_args }
        end,
        desc = "Run with Args",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to Line (No Execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dP",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
    },

    config = function()
      local dap = require "dap"

      -- Mason auto-install adapters
      local ok_mason, mason_dap = pcall(require, "mason-nvim-dap")
      if ok_mason then
        mason_dap.setup()
      end

      -- Highlight stopped line
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      -- Define signs
      local icons = { Breakpoint = "", LogPoint = "", Stopped = "" }
      for name, sign in pairs(icons) do
        vim.fn.sign_define("Dap" .. name, { text = sign, texthl = "DiagnosticInfo" })
      end

      -- dap-ui
      require("dapui").setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        require("dapui").open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        require("dapui").close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        require("dapui").close()
      end

      -- virtual-text
      require("nvim-dap-virtual-text").setup()

      -- Load launch.json if present
      local ok_vscode, vscode = pcall(require, "dap.ext.vscode")
      if ok_vscode then
        local json = require "plenary.json"
        vscode.json_decode = function(str)
          return vim.json.decode(json.json_strip_comments(str))
        end
        vscode.load_launchjs(nil, { codelldb = { "c", "cpp" } })
      end
    end,
  },
  {
    "nvim-neotest/nvim-nio",
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
      },
    },
    -- mason-nvim-dap is loaded when nvim-dap loads
    config = function() end,
  },
}
