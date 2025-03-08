local prefill_edit_window = function(request)
  require('avante.api').edit()
  local code_bufnr = vim.api.nvim_get_current_buf()
  local code_winid = vim.api.nvim_get_current_win()
  if code_bufnr == nil or code_winid == nil then
    return
  end
  vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
  -- Optionally set the cursor position to the end of the input
  vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
  -- Simulate Ctrl+S keypress to submit
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, true, true), 'v', true)
end

local keys_file = os.getenv("HOME") .. '/.keys'

local dependencies = {
  "nvim-treesitter/nvim-treesitter",
  "stevearc/dressing.nvim",
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  --- The below dependencies are optional,
  "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  "ibhagwan/fzf-lua", -- for file_selector provider fzf
  "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  {
    -- Make sure to set this up properly if you have lazy=true
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" },
  }
}

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",

  enabled = function()
    local util = require('util')
    return util.is_file( keys_file ) and util.is_dir( vim.fn.getcwd() .. '/.git' )
  end,
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = dependencies,
  config = function()
    local keys = vim.json.decode(require('util').read_file(keys_file))

    for k, v in pairs(keys) do
      vim.env[ string.upper(k) .. '_API_KEY' ] = v
    end

    local vendors = {
      openrouter = {
        __inherited_from = 'openai',
        endpoint = 'https://openrouter.ai/api/v1',
        api_key_name = 'OPENROUTER_API_KEY',
        model = 'google/gemini-2.0-flash-001',
        disable_tools = true
      }
    }

    local options = {
      -- add any opts here
      -- for example
      provider = "openrouter",
      vendors = vendors,
    }

    require("avante").setup(options)

  end,
}
