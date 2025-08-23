return {
  'saghen/blink.cmp',
  version = '1.*',
  dependencies = {
    { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    "mikavilpas/blink-ripgrep.nvim",
    "xzbdmw/colorful-menu.nvim",
  },

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
    keymap = { preset = 'enter' },

    snippets = { preset = 'luasnip' },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'normal'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = {
      documentation = { auto_show = true },
      list = { selection = { preselect = false } },
      menu = {
        border = 'single' ,
        draw = {
          columns = { { 'kind_icon', 'label', 'label_description', gap = 2 } },
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
            label = {
              text      = function(ctx) return require("colorful-menu").blink_components_text(ctx) end,
              highlight = function(ctx) return require("colorful-menu").blink_components_highlight(ctx) end,
            },
          }
        }
      }
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'snippets', 'buffer', 'lsp', 'path' },
      -- default = { 'snippets', 'lsp', 'path', 'buffer' },
      providers = {
        -- include all buffers instead of just visible ones
        buffer = {
          opts = {
            get_bufnrs = function()
              return vim.tbl_filter(
                function(bufnr) return vim.bo[bufnr].buftype == '' end,
                vim.api.nvim_list_bufs())
            end
          },
        },
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
        },
      },
    },

    fuzzy = { implementation = "prefer_rust" },

    signature = { window = { border = 'single' } },
  },
  opts_extend = { "sources.default" }
}
