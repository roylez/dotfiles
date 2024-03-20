return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons", optional = true },
    config = function()
      require("fzf-lua").setup({ "max-perf" })

      vim.cmd [[
        nnoremap <silent> <leader>/ <cmd>lua require('fzf-lua').grep()<CR>
        nnoremap <silent> <leader>b <cmd>lua require('fzf-lua').buffers()<CR>
        nnoremap <silent> <leader>f <cmd>lua require('fzf-lua').files()<CR>
        nnoremap <silent> <leader>T <cmd>lua require('fzf-lua').tags()<CR>
        " nnoremap <silent> <leader>t <cmd>lua require('fzf-lua').btags()<CR>
        " nnoremap <silent> <leader>s :Snippets<CR>
      ]]
    end
}
