return {
  "L3MON4D3/LuaSnip",
  -- follow latest release.
  version = "v2.*",
  dependencies = { "ibhagwan/fzf-lua" },
  config = function()
    require("luasnip.loaders.from_snipmate").lazy_load()

    vim.cmd [[
      command! LuaSnipEdit :lua require("luasnip.loaders").edit_snippet_files()
      ]]

    vim.keymap.set(
      'i', ',,',

      function()
        local fzf = require('fzf-lua')
        local snip  = require('luasnip')

        local items = {}
        for sub_type in string.gmatch(vim.o.filetype, "%w+") do
          local snippets = snip.get_snippets(sub_type)
          for _, snippet in ipairs(snippets) do
            table.insert(items, snippet)
          end
        end

        function find_snippet(word)
          for _, v in ipairs( items ) do
            if v.name == word then
              return v
            end
          end
        end

        fzf.fzf_exec(
          function(fzf_cb)
            for _, v in ipairs( items ) do
              fzf_cb( v.name )
            end
            fzf_cb()
          end,
          {
            prompt = "SNIPPET> ",
            preview = { fn = function(s) return find_snippet(s[1]):get_docstring() end },
            actions = {
              ["default"] = function(s) snip.snip_expand(find_snippet(s[1])) end
            }
          }
        )
      end
    )

  end
}
