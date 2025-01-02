return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      patterns = { ".git", "Makefile", "mix.exs" },
    })
  end
}
