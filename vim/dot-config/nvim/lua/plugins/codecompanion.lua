local keys_file = os.getenv("HOME") .. '/.keys'

local prompt_library = {
  ["Support Rewrite"] = {
    strategy = 'inline',
    description = "Write documentation for me",
    prompts = {
      {
        role = "user",
        content = function(context)
          local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

          return [[
          I want you act as a proofreader. I will provide you texts and I would like you to review them

          - Correct any spelling, grammar, or punctuation errors.
          - Make the text to read more naturally but still looks professional.
          - Do not use any contractions like I'm or you're.
          - Just send me the revised text without anything else.

          The text is here

          ```
          ]] .. text .. [[
          ```
          ]]
        end,
      }
    },
    opts = {
      modes = { "v" },
      short_name = 'rewrite',
      auto_submit = true,
      stop_context_insertion = true,
    }
  }
}

local opts = {
  opts = {
    log_level = "DEBUG",
  },
  adapters = {
    opts = { show_defaults = false },
    openrouter = function()
      return require("codecompanion.adapters").extend("openai_compatible", {
        env = {
          url = "https://openrouter.ai/api",
          api_key = "OPENROUTER_API_KEY",
          chat_url = "/v1/chat/completions",
        },
        schema = {
          model = {
            default = "google/gemini-2.0-flash-001",
          },
        },
      })
    end
  },
  strategies = {
    chat   = { adapter = "openrouter", model = "anthropic/claude-3.5-sonnet" },
    inline = { adapter = "openrouter", model = "google/gemini-2.0-flash-001" },
  },
  display = {
    chat = {
      window = { position = "right" },
    },
    -- diff = { provider = 'mini_diff' }
  },
  prompt_library = prompt_library
}

return {
  "olimorris/codecompanion.nvim",

  lazy = false,

  dependencies = {
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    {"nvim-lua/plenary.nvim", branch = "master"},
    "hrsh7th/nvim-cmp",
    "folke/which-key.nvim",
  },

  enabled = function()
    return require('util').is_file( keys_file )
  end,

  config = function()
    local keys = vim.json.decode(require('util').read_file(keys_file))

    for k, v in pairs(keys) do
      vim.env[ string.upper(k) .. '_API_KEY' ] = v
    end

    require("codecompanion").setup(opts)

    local wk = require('which-key')
    wk.add({
      nowait=true, remap=false, mode={ 'n', 'v' },
      {'<leader>c', ':CodeCompanionChat toggle<CR>', desc="AI Chat" },
      {'<leader>a', ':CodeCompanionActions<CR>',     desc="AI Actions"},
      {'<leader>W', ':CodeCompanion /rewrite<CR>',   desc="AI rewrite"},
    })
  end
}
