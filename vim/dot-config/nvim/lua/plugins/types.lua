return {

  { 'ledger/vim-ledger',       ft = 'ledger' },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion", "yaml" },
    opts = {
      code = {
          width = 'block',
          min_width = 45,
          left_pad = 4,
          language_pad = 4,
      },
      heading = {
        border = true, border_virtual = true,
      },
      checkbox = {
        custom = {
          todo   = { raw = '[>]', rendered = ' ', highlight = 'DiagnosticWarn' },
          cancel = { raw = '[-]', rendered = ' ', highlight = 'DiagnosticError' },
        },
      },
    }
  },

}
