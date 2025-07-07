return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      enabled = false,
    },
    picker = {
      enabled = true,
    },
    input = {
      enabled = true,
    },
    indent = {
      enabled = true,
      indent = {
        only_scope = true,
      },
      chunk = {
        enabled = true,
        char = {
          arrow = "─",
          corner_top = "╭",
          corner_bottom = "╰",
        },
      },
    },
    notifier = {
      enabled = true,
    },
  },
}
