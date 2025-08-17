return {
  "neovim/nvim-lspconfig",
  dependencies = { 'saghen/blink.cmp' },
  opts = {
    servers = {
      elixirls = {
        cmd = { os.getenv("HOME") .. "/workspace/3.resources/elixir-ls/language_server.sh" },
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
}
