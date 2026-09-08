return {
  "frankroeder/parrot.nvim",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim"
  },
  enabled = require('util').has_keys,
  keys = {
    {'<leader>W', ':PrtRewrite ProofReader<CR>',  mode="v",  desc="AI auto-rewrite"},
    {'<leader>w', ':PrtRewrite ', mode='v', desc="AI rewrite"}
  },
  ft = { 'markdown', 'markdown.scratch', 'mail' },
  opts = {
    providers = {
      litellm = {
        name = "litellm",
        api_key = os.getenv "LLMGATEWAY_API_KEY",
        endpoint = "https://ai.roylez.info/chat/completions",
        models = { "glm-5.3-flash" },
        headers = function(self)
          return {
            ["X-LiteLLM-Agent-Id"] = "ParrotNvim",
            ["Content-Type"] = "application/json",
            ["X-API-Key"] = self.api_key
          }
        end
      },
    }
  }
}
