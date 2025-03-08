local M={}

-- preserve cusror location for after some vim commands
M.preserve = function(arguments)
  local arguments = string.format("keepjumps keeppatterns execute %q", arguments)
  -- local original_cursor = vim.fn.winsaveview()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_command(arguments)
  local lastline = vim.fn.line("$")
  -- vim.fn.winrestview(original_cursor)
  if line > lastline then
    line = lastline
  end
  vim.api.nvim_win_set_cursor( 0 , { line, col })
end

-- test if a file exists
M.is_file = function(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end

-- test if a directory exists
M.is_dir = function(name)
  local f = io.open(name, "r")
  if f then
    io.close(f)
    local handle = io.popen("test -d " .. name)
    local result = handle:read()
    handle:close()
    return result == nil
  else
    return false
  end
end

-- read in a file
M.read_file = function(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local content = file:read "*a"
  file:close()
  return content
end

-- create a menu using vim.ui.select
M.create_menu = function( prompt, items )

  local prompt = ( prompt == nil and "Choose ..." or prompt ) .. " > "
  local option_names = {}
  local n = 0
  for i, _ in pairs(items) do
    n = n + 1
    option_names[n] = i
  end
  table.sort(option_names)

  -- Return the prompt function. These global function var will be used when assigning keybindings
  local menu = function()
    vim.ui.select(
      option_names,
      { prompt = prompt },
      function(choice)
        local action = items[choice]
        -- When user inputs ESC or q, don't take any actions
        if action ~= nil then
          if type(action) == "string" then
            vim.cmd(action)
          elseif type(action) == "function" then
            action()
          end
        end

      end)
  end

  return menu
end

return M
