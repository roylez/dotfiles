function file_exists(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end

return
  {
    "jackMort/ChatGPT.nvim",
    enabled = function()
      return file_exists( os.getenv("HOME") .. "/.gpt" )
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
      "folke/which-key.nvim",
    },
    config = function()
      local custom_actions =  os.getenv("HOME") .. '/.config/nvim/chatgpt.json'

      local chatgpt = require("chatgpt")

      chatgpt.setup({
        -- api_host_cmd = 'sed -n 2p ' .. os.getenv("HOME") .. '/.gpt',
        api_key_cmd = 'sed -n 1p ' .. os.getenv("HOME") .. '/.gpt',
        actions_paths = { custom_actions },
      })

      local wk = require("which-key")
      local action_keys = "jq -r 'keys[]' " .. custom_actions
      local fzf = require("fzf-lua")

      wk.register({
        c = {
          name = "ChatGPT",
          c = { "<cmd>ChatGPT<CR>", "提问" },
          e = { "<cmd>ChatGPTEditWithInstruction<CR>", "辅助编辑", mode = { "n", "v" } },
          r = {
            function()
              fzf.fzf_exec( action_keys,
                {
                  prompt = "ChatGPT Run> ",
                  actions = {
                    ["default"] = function(selected, opts)
                      vim.cmd( "stopinsert" )
                      vim.cmd( { cmd = "ChatGPTRun" , args = selected } )
                    end
                  }
                }
              )
            end,
            "运行...", mode = {"n", "v"}
          }
        },
      }, { prefix = "<leader>" })
    end,
  }
