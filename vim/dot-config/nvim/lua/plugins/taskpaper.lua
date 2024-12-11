function replace_old_dues()
  local current_line
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local today = os.date("*t", os.time())
  today = os.time({year=today.year, month=today.month, day=today.day})
  for i, line in ipairs(lines) do
    lines[i] = line:gsub("@due%((%d%d%d%d)%-(%d%d)%-(%d%d)%)", function(year, month, day)
      local date = os.time({year=tonumber(year), month=tonumber(month), day=tonumber(day)})
      if date <= today then
        return "@today"
      else
        return "@due(" .. year .. "-" .. month .. "-" .. day .. ")"
      end
    end)
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

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
      vim.keymap.set('n', 'q',    ':x<CR>',                            { silent = true, buffer = true })

      wk.add(
        {
          { "<leader>t", group = "TaskPaper" },
          { "<leader>tD",
            function()
              vim.api.nvim_call_function("taskpaper#archive_done", {})
              -- require('util').preserve("call taskpaper#archive_done()")
            end,
            desc = "归档" },
          { "<leader>tT",
            function()
              replace_old_dues()
              vim.cmd( ":call taskpaper#search_tag('today')" )
            end,
            desc = '显示当日' },
          { "<leader>td",
            function()
              if vim.api.nvim_call_function('taskpaper#has_tag', { 'done' }) == 1 then
                vim.api.nvim_call_function('taskpaper#delete_tag', { 'done' })
              else
                vim.api.nvim_call_function('taskpaper#delete_tag', { 'today' })
                vim.api.nvim_call_function('taskpaper#add_tag', { 'done', os.date("%Y-%m-%d", os.time()) })
              end
            end, desc = '标注 @done' },
          { "<leader>ts", ":call taskpaper#search()<CR>", desc = "搜索..." },
          { "<leader>tt", ":call taskpaper#toggle_tag('today', '')<CR>", desc = "标注 @today" },
        }
      )

    end,
  }
