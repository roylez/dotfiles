return {
  'dcampos/nvim-snippy',
  dependencies = {
    "ibhagwan/fzf-lua",
  },
  config = function()
    local snippy = require('snippy')

    snippy.setup({
      mappings = {
        is = {
          ['<Tab>'] = 'expand_or_advance',
          ['<S-Tab>'] = 'previous',
        },
        nx = {
          ['<leader>x'] = 'cut_text',
        },
      },
    })

    vim.keymap.set(
      'i', ',,',

      function()
        local fzf = require('fzf-lua')
        local items = snippy.get_completion_items()

        function find_snippet(word)
          for i, v in ipairs( items ) do
            if v.word == word then
              return v.user_data.snippy.snippet
            end
          end
        end

        fzf.fzf_exec(
          function(fzf_cb)
            for i, v in ipairs( items ) do
              fzf_cb( v.word )
            end
            fzf_cb()
          end,
          {
            prompt = "SNIPPET> ",
            preview = {
              fn = function(s) return find_snippet(s[1]).body end
            },
            actions = {
              ["default"] = function(s) snippy.expand_snippet(find_snippet(s[1])) end
            }
          }
        )
      end
    )
  end
}
