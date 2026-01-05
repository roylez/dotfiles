return {
  {
    "williamboman/mason.nvim",
    opts = {}
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {}
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp' },
    opts = {
      servers = {
        lexical = {
          cmd = { '~/.local/share/nvim/mason/bin/expert', '--stdio' },
          filetypes = { "elixir", "eelixir", "heex" },
          root_markers = { "mix.exs", ".git" },
        },
        tinymist = {
          single_file_support = true,
          settings = {
            exportPdf = "onSave",
          },
        }
      }
    },

    config = function(_, opts)
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      for server, config in pairs(opts.servers) do
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
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
  },

  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    keys = {
      {'<leader>P', ':TypstPreview<CR>',  mode="n", desc="[TYPST] Preview"}
    },
    version = "1.*",
    build = function() require "typst-preview".update() end,
  }
}
