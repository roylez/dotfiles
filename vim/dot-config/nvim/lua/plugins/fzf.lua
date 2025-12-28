return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "echasnovski/mini.icons",
  },
  config = function()
    local fzf = require("fzf-lua")
    local actions = require("fzf-lua.actions")

    fzf.setup({ "fzf-native",
      keymap = {
        fzf = {
          -- send all to quickfix
          ["ctrl-q"] = "select-all+accept",
        }
      }
    })

    fzf.register_ui_select()

    vim.keymap.set('n', '<leader>/',
      function() fzf.live_grep({ header = '[c-q] QuickFix | [c-g] Fuzzy' }) end,
      { silent = true, desc = '[FZF] rg'})
    vim.keymap.set('n', '<leader>b', fzf.buffers,   { silent = true, desc = '[FZF] buffers' })
    vim.keymap.set('n', '<leader>f', fzf.files,     { silent = true, desc = '[FZF] files' })
    vim.keymap.set('n', '<leader>r', fzf.oldfiles,  { silent = true, desc = '[FZF] MRU' })
    vim.keymap.set('n', '<leader>.', fzf.resume,    { silent = true, desc = '[FZF] RESUME' })

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
    end, { silent = true, desc = '[FZF] ...' })

  end
}
