return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "echasnovski/mini.icons",
  },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({ "fzf-native" })

    fzf.register_ui_select()

    local actions = require("fzf-lua.actions")

    vim.keymap.set('n', '<leader>/', fzf.live_grep, { silent = true, desc = 'Search with Rg' })
    vim.keymap.set('n', '<leader>b', fzf.buffers,   { silent = true, desc = 'Search Buffers' })
    vim.keymap.set('n', '<leader>f', fzf.files,     { silent = true, desc = 'Search Files' })
    vim.keymap.set('n', '<leader>r', fzf.oldfiles,  { silent = true, desc = 'Search MRU' })
    vim.keymap.set('n', '<leader>u', fzf.resume,    { silent = true, desc = 'Resume' })

    local keyset={}
    local n=0

    for k,v in pairs(fzf) do
      if not k:match("^_") then
        n=n+1
        keyset[n]=k
      end
    end
    table.sort(keyset)

    vim.keymap.set({'n'}, '<leader>F', function()
      fzf.fzf_exec(keyset, {
        prompt = 'FZF...> ',
        actions = {
          ["default"] = function(selected, opts)
            fzf[selected[1]]()
          end
        }
      })
    end, { silent = true, desc = 'Search ...' })

  end
}
