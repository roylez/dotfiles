return {
  {
  "neovim/nvim-lspconfig",
  dependencies = { 'saghen/blink.cmp' },
  opts = {
    servers = {
      lexical = {
        cmd = { os.getenv("HOME") .. "/workspace/3.resources/lexical/bin/start_lexical.sh" },
        filetypes = { "elixir", "eelixir", "heex" },
        root_markers = { "mix.exs", ".git" },
      }
    }
  },
  config = function(_, opts)
    local lspconfig = require("lspconfig")
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    for server, config in pairs(opts.servers) do
      config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
      lspconfig[server].setup(config)
    end
  end
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require('tiny-inline-diagnostic').setup()
      vim.diagnostic.config({ virtual_text = false })
    end
  }
}
