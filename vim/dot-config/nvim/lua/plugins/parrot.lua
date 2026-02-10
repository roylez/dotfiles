return {
  "frankroeder/parrot.nvim",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim"
  },
  enabled = require('util').has_keys,
  keys = {
    {'<leader>W', ':PrtRewrite ProofReader<CR>',  mode="v",  desc="AI rewrite"}
  },
  ft = { 'markdown', 'markdown.scratch', 'mail' },
  opts = {
    providers = {
      openrouter = {
        name = "openrouter",
        api_key = os.getenv "OPENROUTER_API_KEY",
        endpoint = "https://openrouter.ai/api/v1/chat/completions",
        models = {
          "z-ai/glm-4.5-air:free",
          "google/gemini-2.5-flash",
        }
      },
    }
  }
}
