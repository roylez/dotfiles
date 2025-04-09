local mode = {
  "mode",
  fmt = function(s)
    local mode_map = {
      ["NORMAL"] = "N",
      ["O-PENDING"] = "N?",
      ["INSERT"] = "I",
      ["VISUAL"] = "V",
      ["V-BLOCK"] = "VB",
      ["V-LINE"] = "VL",
      ["V-REPLACE"] = "VR",
      ["REPLACE"] = "R",
      ["COMMAND"] = "!",
      ["SHELL"] = "SH",
      ["TERMINAL"] = "T",
      ["EX"] = "X",
      ["S-BLOCK"] = "SB",
      ["S-LINE"] = "SL",
      ["SELECT"] = "S",
      ["CONFIRM"] = "Y?",
      ["MORE"] = "M",
    }
    return mode_map[s] or s
  end,
}

local function codecompanion_adapter_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  return chat and " " .. chat.adapter.formatted_name or nil
end

local function codecompanion_current_model_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  return chat and chat.settings.model or nil
end

local codecompanion_extension = {
  filetypes = { "codecompanion" },
  sections = {
    lualine_a = {
      mode,
    },
    lualine_b = {
      codecompanion_adapter_name,
    },
    lualine_c = {
      codecompanion_current_model_name,
    },
    lualine_x = {},
    lualine_y = {
      "progress",
    },
    lualine_z = {
      "location",
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {
      codecompanion_adapter_name,
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
      "progress",
    },
    lualine_z = {},
  },
}

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = 'dracula',
      section_separators = '',
      component_separators = '·',
      icons_enabled = false,
    },
    sections = {
      lualine_a = { mode }
    },
    extensions = {
      'oil',
      'quickfix',
      codecompanion_extension,
    }
  }
}
