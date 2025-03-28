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
      lualine_a = {
        { 'mode',
          fmt = function(str)
            return str == 'INSERT' and str or str:sub(1,1)
          end
        }
      }
    }
  }
}
