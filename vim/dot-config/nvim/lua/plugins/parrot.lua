return {
  "frankroeder/parrot.nvim",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim"
  },
  enabled = require('util').has_keys,
  keys = {
    {'<leader>W', '<cmd>PrtRewrite ProofReader<CR>',  mode="v",  desc="AI rewrite"}
  },
  opts = {
    providers = {
      openrouter = {
        style = "openai",
        name = "openrouter",
        api_key = os.getenv "OPENROUTER_API_KEY",
        endpoint = "https://openrouter.ai/api/v1/chat/completions",
        models = {
          "google/gemini-2.0-flash-001",
        }
      }
    }
  }
}
