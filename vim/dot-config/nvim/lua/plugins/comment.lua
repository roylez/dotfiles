return {
  'numToStr/Comment.nvim',
  lazy = false,
  config = function()
    require('Comment').setup()
    vim.cmd [[
      vmap <F9> gcc
      nmap <F9> gcc
    ]]
  end,
}
