return {
  'rmehri01/onenord.nvim',
  priority = 9000,
  lazy = false,
  config = function()
    require('onenord').setup()
  end
}
