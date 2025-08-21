return {

  { 'pearofducks/ansible-vim', ft = 'ansible' },

  { 'vim-crystal/vim-crystal', ft = 'crystal' },

  { 'ledger/vim-ledger',       ft = 'ledger' },

  {
    'elixir-editors/vim-elixir',
    config = function()
      vim.cmd [[
        autocmd BufNewFile,BufRead tmp.*.erl set ft=elixir
        autocmd FileType elixir,eelixir setlocal shiftwidth=2
        autocmd BufNewFile,BufRead *.leex,*.heex setlocal ft=html.eelixir
      ]]
    end
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    opts = {
      code = {
          width = 'block',
          min_width = 45,
          left_pad = 4,
          language_pad = 4,
      },
      heading = { border = true, border_virtual = true, },
      checkbox = {
        custom = {
          todo   = { raw = '[+]', rendered = '󰥔 ', highlight = 'RenderMarkdownWarning',   scope_highlight = nil },
          cancel = { raw = '[-]', rendered = '󰜺 ', highlight = 'RenderMarkdownUnchecked', scope_highlight = nil },
        },
      }
    }
  },

}
