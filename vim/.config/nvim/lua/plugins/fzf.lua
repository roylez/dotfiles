return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons", optional = true },
    config = function()
      local fzf = require("fzf-lua")

      fzf.setup({ "max-perf" })

      local keyset={}
      local n=0

      for k,v in pairs(fzf) do
        if not k:match("^_") then
          n=n+1
          keyset[n]=k
        end
      end

      local actions = require("fzf-lua.actions")

      vim.keymap.set({'n'}, '<leader>/', fzf.live_grep, { silent = true, desc = 'Fuzzy Search' })
      vim.keymap.set({'n'}, '<leader>b', fzf.buffers,   { silent = true, desc = 'Fuzzy Buffers' })
      vim.keymap.set({'n'}, '<leader>f', fzf.files,     { silent = true, desc = 'Fuzzy Files' })
      vim.keymap.set({'n'}, '<leader>t', fzf.tags,      { silent = true, desc = 'Fuzzy Tags' })
      vim.keymap.set({'n'}, '<leader>F', function()
        local fzf = require("fzf-lua")
        fzf.fzf_exec(keyset, {
          prompt = 'FZF...> ',
          actions = {
            ["default"] = function(selected, opts)
              fzf[selected[1]]()
            end
          }
        })
      end, { silent = true, desc = 'Fuzzy ...' })

    end
}
