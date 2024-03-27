return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons", optional = true },
    config = function()
      local fzf = require("fzf-lua")

      fzf.setup({ "max-perf" })

      local actions = require("fzf-lua.actions")

      vim.keymap.set({'n'}, '<leader>/', fzf.live_grep, { silent = true, desc = 'Rg' })
      vim.keymap.set({'n'}, '<leader>b', fzf.buffers,   { silent = true, desc = 'Buffers' })
      vim.keymap.set({'n'}, '<leader>f', fzf.files,     { silent = true, desc = 'Files' })

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
      end, { silent = true, desc = 'Fuzzy...' })

    end
}
