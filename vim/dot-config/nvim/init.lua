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

-- {{{ setting modes
vim.g.neovim_mode = vim.env.NEOVIM_MODE or "default"
-- }}}

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
      vim.api.nvim_echo({ { "󰆓  ", "LazyProgressDone" }, { " file autosaved at " .. time } }, false, {})

      clear_cmdarea()
    end
  end,
})
--- }}}

--- {{{ goto today's heading in TODO.md
local function goto_today_heading()
  local today = os.date("%Y-%m-%d")
  local search_pattern = "^## " .. today

  -- Search from cursor position, wrapping if needed
  vim.fn.search(search_pattern, "w")
end

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "TODO.md",
  callback = function()
    -- Buffer-local mapping for 'g ' (g followed by space)
    vim.keymap.set('n', '  ', goto_today_heading, {
      buffer = true,
      desc = "Go to TODAY"
    })
  end,
})
--- }}}

--- {{{ quickfix toggling
local function toggle_quickfix()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      vim.cmd.cclose()
      return
    end
  end
  vim.cmd.copen()
end

vim.keymap.set('n', '<Leader>c', toggle_quickfix, { desc = "Toggle Quickfix Window" })
--- }}}

--- {{{ pager mode for kitty
if vim.g.neovim_mode == "pager" then
  vim.cmd [[
    colorscheme vim
    set eventignore=FileType
    set readonly nolist nomodifiable nospell syntax=
    set clipboard=unnamed,unnamedplus
    set laststatus=0
  ]]

  vim.keymap.set({'n', 'v'}, 'q', [[<cmd>q!<cr>]])
  vim.keymap.set({'n', 'v'}, 'y', [[y<cmd>q!<cr>]])

  local b = vim.api.nvim_create_buf(false, true)
  local chan = vim.api.nvim_open_term(b, {})
  vim.api.nvim_chan_send(chan, table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
  vim.api.nvim_win_set_buf(0, b)

  vim.cmd.normal("G")
end
--- }}}
