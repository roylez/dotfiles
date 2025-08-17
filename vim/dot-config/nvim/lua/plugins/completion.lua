-- local M = {
--   "hrsh7th/nvim-cmp",
--   dependencies = {
--     "hrsh7th/cmp-nvim-lsp",
--     "hrsh7th/cmp-nvim-lua",
--     "hrsh7th/cmp-buffer",
--     "hrsh7th/cmp-path",
--     "hrsh7th/cmp-cmdline",
--     'dcampos/cmp-snippy',
--     'dcampos/nvim-snippy',
--     'onsails/lspkind.nvim',
--   },
-- }
--
-- local has_words_before = function()
--   unpack = unpack or table.unpack
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end
--
-- M.config = function()
--   local cmp = require("cmp")
--   local lspkind = require('lspkind')
--   local snippy = require("snippy")
--
--   vim.opt.completeopt = { "menu", "menuone", "noselect" }
--
--   local source_mapping = {
--     buffer      = "[B]",
--     nvim_lsp    = "[LSP]",
--     nvim_lua    = "[LUA]",
--     path        = "[F]",
--     snippy      = '[SNIP]',
--     dictionary  = '[D]',
--     cmp_tabnine = "[TN]",
--     codeium     = '[AI]',
--   }
--
--   local symbol_mapping = {
--     Codeium = '',
--   }
--
--   cmp.setup({
--     snippet = {
--       expand = function(args)
--         snippy.expand_snippet(args.body)
--       end,
--     },
--     window = {
--       -- completion = cmp.config.window.bordered(),
--       -- documentation = cmp.config.window.bordered(),
--     },
--     formatting = {
--       format = lspkind.cmp_format({
--         mode = 'symbol',
--         menu = ( source_mapping ),
--         symbol_map = symbol_mapping,
--         maxwidth = 50,
--         ellipsis_char = '...',
--         show_labelDetails = true
--       })
--     },
--     mapping = {
--       ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
--       ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
--       ['<C-n>'] = cmp.mapping({
--         c = function()
--           if cmp.visible() then
--             cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
--           else
--             vim.api.nvim_feedkeys(t('<Down>'), 'n', true)
--           end
--         end,
--         i = function(fallback)
--           if cmp.visible() then
--             cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
--           else
--             fallback()
--           end
--         end
--       }),
--       ['<C-p>'] = cmp.mapping({
--         c = function()
--           if cmp.visible() then
--             cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
--           else
--             vim.api.nvim_feedkeys(t('<Up>'), 'n', true)
--           end
--         end,
--         i = function(fallback)
--           if cmp.visible() then
--             cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
--           else
--             fallback()
--           end
--         end
--       }),
--       ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
--       ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
--       ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
--       ['<C-e>'] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
--       ['<CR>'] = cmp.mapping({
--         i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
--         c = function(fallback)
--           if cmp.visible() then
--             cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
--           else
--             fallback()
--           end
--         end
--       }),
--     },
--     sources = cmp.config.sources({
--       { name = "snippy", max_item_count = 5 },
--       -- { name = 'codeium' },
--       { name = "nvim_lsp" },
--       { name = "buffer" },
--       { name = "path" },
--     }, { }),
--
--     experimental = {
--       ghost_text = true
--     },
--
--     performance = {
--       -- needed to accommodate slow AI completions
--       fetching_timeout = 2000,
--     }
--
--   })
--
--   cmp.setup.filetype('mail', {
--     sources = {
--       { name = "snippy", max_item_count = 5 },
--       { name = "buffer" }
--     }
--   })
-- end
--
-- return M

return {
  'saghen/blink.cmp',
  version = '1.*',
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'super-tab',
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'normal'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      documentation = { auto_show = true },
      menu = {
        draw = {
          columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
          components = {
            kind_icon = {
              text = function(ctx)
                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                return kind_icon
              end,
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
            kind = {
              -- (optional) use highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
            item_idx = {
              text = function(ctx) return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx) end,
            },
          }
        }
      }
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        -- include all buffers instead of just visible ones
        buffer = {
          opts = {
            get_bufnrs = function()
              return vim.tbl_filter(
                function(bufnr) return vim.bo[bufnr].buftype == '' end,
                vim.api.nvim_list_bufs())
            end
          }
        }
      },
    },

    fuzzy = { implementation = "prefer_rust" },
  },
  opts_extend = { "sources.default" }
}
