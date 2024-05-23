return {
  {
    'roylez/zwiki',
    lazy = false,
    dependencies = { 'vimwiki/vimwiki', "ibhagwan/fzf-lua" }
  },

  {
    'vimwiki/vimwiki',
    config = function()
      vim.cmd [[
        let g:vimwiki_table_mappings = 0
        let g:vimwiki_auto_chdir     = 1
        let g:vimwiki_hl_cb_checked  = 2
        let g:vimwiki_global_ext     = 0
        let g:vimwiki_create_link    = 0
        let g:vimwiki_list = [{'path': '~/wiki/', 'syntax': 'markdown', 'ext': '.md', 'auto_diary_index': 1}]
        autocmd FileType vimwiki setlocal spell
        autocmd FileType vimwiki nnoremap tt :VimwikiToggleListItem<CR>
      ]]
    end
  }
}
