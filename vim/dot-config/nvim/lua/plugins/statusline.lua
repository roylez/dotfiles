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

local encoding = {
  "encoding",
  fmt = function(s) return s == "utf-8" or s end
}

local fileformat = {
  "fileformat",
  fmt = function(s) return s == "unix" or s end
}

-- define function and formatting of the information
local function parrot_model()
  local status_info = require("parrot.config").get_status_info()
  return status_info.model
end

return {
  'nvim-lualine/lualine.nvim',
  -- dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      -- theme = 'dracula',
      theme = 'onenord',
      section_separators = '',
      component_separators = '·',
      icons_enabled = false,
    },
    sections = {
      lualine_a = { mode },
      lualine_b = { "diff", "diagnostics" },
      lualine_x = { encoding, fileformat, "filetype" },
    },
    extensions = {
      'oil',
      'quickfix'
    }
  }
}
