return {
  "nvim-tree/nvim-web-devicons",
  dependencies = { "lambdalisue/glyph-palette.vim" },
  config = function()
    vim.cmd [[
      augroup GlyphPalette
        autocmd!
        autocmd FileType fern call glyph_palette#apply()
        autocmd FileType nerdtree,startify call glyph_palette#apply()
      augroup END
    ]]
  end
}
