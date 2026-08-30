return {

  { 'ledger/vim-ledger',       ft = 'ledger' },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = function()
      return vim.o.filetype == "markdown" and vim.fn.expand("%:t") ~= "TODO.md"
    end,
    opts = {
      code = {
          width = 'block',
          min_width = 45,
          left_pad = 4,
          language_pad = 4,
      },
      heading = {
        position = 'inline'
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
