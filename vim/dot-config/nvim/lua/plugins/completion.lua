local M = {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    'dcampos/cmp-snippy',
    'dcampos/nvim-snippy',
    'onsails/lspkind.nvim',
  },
}

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

M.config = function()
  local cmp = require("cmp")
  local lspkind = require('lspkind')
  local snippy = require("snippy")

  vim.opt.completeopt = { "menu", "menuone", "noselect" }

  local source_mapping = {
    buffer      = "[B]",
    nvim_lsp    = "[LSP]",
    nvim_lua    = "[LUA]",
    path        = "[F]",
    snippy      = '[SNIP]',
    dictionary  = '[D]',
    cmp_tabnine = "[TN]",
    codeium     = '[AI]',
  }

  local symbol_mapping = {
    Codeium = '',
  }

  cmp.setup({
    snippet = {
      expand = function(args)
        snippy.expand_snippet(args.body)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol',
        menu = ( source_mapping ),
        symbol_map = symbol_mapping,
        maxwidth = 50,
        ellipsis_char = '...',
        show_labelDetails = true
      })
    },
    mapping = {
      ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
      ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
      ['<C-n>'] = cmp.mapping({
        c = function()
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            vim.api.nvim_feedkeys(t('<Down>'), 'n', true)
          end
        end,
        i = function(fallback)
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end
      }),
      ['<C-p>'] = cmp.mapping({
        c = function()
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            vim.api.nvim_feedkeys(t('<Up>'), 'n', true)
          end
        end,
        i = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end
      }),
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
      ['<C-e>'] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
      ['<CR>'] = cmp.mapping({
        i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        c = function(fallback)
          if cmp.visible() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end
      }),
    },
    sources = cmp.config.sources({
      { name = "snippy", max_item_count = 5 },
      { name = 'codeium' },
      { name = "nvim_lsp" },
      { name = "buffer" },
      { name = "path" },
    }, { }),

    experimental = {
      ghost_text = true
    }
  })

  -- cmp.setup.cmdline("/", {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = { { name = 'buffer' } }
  -- })

  -- cmp.setup.cmdline(":", {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = cmp.config.sources({
  --     { name = "path" },
  --   }, {
  --       { name = "cmdline" },
  --     }),
  -- })
end

return M
