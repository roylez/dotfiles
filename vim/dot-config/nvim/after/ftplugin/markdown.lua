function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
function ltrim(s)
  return (string.gsub(s, "^%s*(.-)$", "%1"))
end

function string.insert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end

function toggle_todo()
  local current_line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local new_line = ""

  if current_line:find("%- %[X%] ", 1) then
    new_line = string.gsub(current_line, "%- %[X%] ", '', 1)
  elseif current_line:find("%- %[ %] ", 1) then
    new_line = string.gsub(current_line, "%- %[ %] ", "- [X] ", 1)
  else
    new_line = string.gsub(current_line, "^%-?%s*", "- [ ] ", 1)
  end

  vim.api.nvim_buf_set_lines(0, row-1, row, true, {new_line})
end

vim.cmd [[ setlocal comments=n:> textwidth=0 wrapmargin=2 fo=croqnmB1 ]]
vim.keymap.set("n", "tt", toggle_todo, { buffer = true, desc="Toggle DONE" })
