vim.cmd([[

" source normal vim stuff
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

aunmenu *

" gx by default opens a link under the cursor, this opens the current file
nmap gX :lua vim.ui.open(vim.fn.expand("%"))<CR>

]])

--- {{{ load API keys
local util = require('util')
if util.has_keys() then
  util.load_keys()
end
--- }}}

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

--- {{{ autosave TODO.md
local function clear_cmdarea()
  vim.defer_fn(function()
    vim.api.nvim_echo({}, false, {})
  end, 800)
end

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "TODO.md",
  callback = function()
    if #vim.api.nvim_buf_get_name(0) ~= 0 and vim.bo.buflisted then
      vim.cmd "silent w"

      local time = os.date "%I:%M %p"

      -- print nice colored msg
      vim.api.nvim_echo({ { "󰄳", "LazyProgressDone" }, { " file autosaved at " .. time } }, false, {})

      clear_cmdarea()
    end
  end,
})
--- }}}
