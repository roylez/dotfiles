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

      require("chatgpt").setup({
        api_key_cmd = 'cat ' .. os.getenv("HOME") .. '/.gpt',
        actions_paths = { custom_actions },
      })

      local wk = require("which-key")
      local action_keys = "jq -r 'keys[]' " .. custom_actions

      wk.register({
        c = {
          name = "ChatGPT",
          c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
          e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
          g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
          t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
          k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
          d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
          a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
          o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
          s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
          f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
          x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
          r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
          l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
        },
      }, { prefix = "<leader>" })
    end,
  }
