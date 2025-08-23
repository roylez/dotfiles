vim.cmd([[

" source normal vim stuff
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

aunmenu *

" gx by default opens a link under the cursor, this opens the current file
nmap gX :lua vim.ui.open(vim.fn.expand("%"))<CR>

]])

--- {{{ Lazy.nvim
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { import = "plugins" },
  change_detection = { notify = false }
})
--- }}}

