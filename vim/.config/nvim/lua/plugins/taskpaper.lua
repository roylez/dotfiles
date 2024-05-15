return
  {
    "davidoc/taskpaper.vim",
    ft = 'taskpaper',
    dependencies = {
      "folke/which-key.nvim",
    },
    config = function()

      vim.g["task_paper_search_hide_done"] = 1
      vim.g["no_taskpaper_maps"] = 1

      vim.cmd [[
        au BufEnter *.taskpaper setlocal autoindent noexpandtab tabstop=4 shiftwidth=4
      ]]

      local wk = require("which-key")

      vim.keymap.set('n', 'o',    'o<C-r>=taskpaper#newline()<CR>',    { silent = true, buffer = true })
      vim.keymap.set('i', '<CR>', '<CR><C-r>=taskpaper#newline()<CR>', { silent = true, buffer = true })

      wk.register({
        t = {
          name = 'TaskPaper',
          t = { ":call taskpaper#toggle_tag('today', '')<CR>", '标注 @today' },
          s = { ":call taskpaper#search()<CR>",                '搜索...' },
          T = {
            function()
              vim.cmd( ":%s/@due(" .. os.date("%Y-%m-%d", os.time()) .. ".\\{-})/@today/ge" )
              vim.cmd( ":call taskpaper#search_tag('today')" )
            end, '显示当日' },
          d = {
            function()
              if vim.api.nvim_call_function('taskpaper#has_tag', { 'done' }) == 1 then
                vim.api.nvim_call_function('taskpaper#delete_tag', { 'done' })
              else
                vim.api.nvim_call_function('taskpaper#delete_tag', { 'today' })
                vim.api.nvim_call_function('taskpaper#add_tag', { 'done', os.date("%Y-%m-%d", os.time()) })
              end
            end, '标注 @done' },
          D = {
            function()
              require('utils').preserve("call taskpaper#archive_done()")
            end, '归档' },
        }
      },{ prefix = '<leader>' })

    end,
  }
