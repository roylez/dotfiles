return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    local ibl = require "ibl"
    local config = require "ibl.config"
    ibl.setup({ enabled = false })
    vim.keymap.set(
    { "n", "x" },
    "<leader><tab>",
    function()
      ibl.setup_buffer(0, {
        enabled = not config.get_config(0).enabled,
      })
    end,
    { noremap = true, silent = true }
    )
  end
}
