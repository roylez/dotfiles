function file_exists(name)
  local f = io.open(name, "r")
  return f ~= nil and io.close(f)
end

local cred_file = os.getenv("HOME") .. '/.gpt'

local chat_system_prompt = [[
      You are a general AI assistant.

      The user provided the additional info about how they would like you to respond:

      - If you're unsure don't guess and say you don't know instead.
      - Ask question if you need clarification to provide better answer.
      - Think deeply and carefully from first principles step by step.
      - Zoom out first to see the big picture and then zoom in to details.
      - Use Socratic method to improve your thinking and coding skills.
      - Don't elide any code from your output if the answer requires coding.
      - Take a deep breath; You've got this!
      ]]

local code_system_prompt = [[
      You are an AI working as a code editor.

      Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE. START AND END YOUR ANSWER WITH:

      ```
]]


local options = {
  openai_api_key = { "cat", cred_file },

  --- {{{ Agents
  agents = {
    {
      name = "ChatGPT4o",
      chat = true,
      command = false,
      model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
      system_prompt = chat_system_prompt,
    },
    {
      name = "ChatGPT3-5",
      chat = true,
      command = false,
      model = { model = "gpt-3.5-turbo-1106", temperature = 1.1, top_p = 1 },
      system_prompt = chat_system_prompt,
    },
    {
      name = "CodeGPT4",
      chat = false,
      command = true,
      model = { model = "gpt-4-1106-preview", temperature = 0.8, top_p = 1 },
      system_prompt = code_system_prompt,
    },
    {
      name = "CodeGPT4o",
      chat = false,
      command = true,
      model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
      system_prompt = code_system_prompt,
    },
  },
  --- }}}

  hooks = {
    -- {{{ InspectPlugin
    InspectPlugin = function(plugin, params)
      local bufnr = vim.api.nvim_create_buf(false, true)
      local copy = vim.deepcopy(plugin)
      local key = copy.config.openai_api_key
      copy.config.openai_api_key = key:sub(1, 3) .. string.rep("*", #key - 6) .. key:sub(-3)
      local plugin_info = string.format("Plugin structure:\n%s", vim.inspect(copy))
      local params_info = string.format("Command params:\n%s", vim.inspect(params))
      local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_win_set_buf(0, bufnr)
    end,
    -- }}}

    --  {{{ GpImplement rewrites the provided selection/range based on comments in it
    Implement = function(gp, params)
      local template = [[
      Having following from {{filename}}:

      ``` {{filetype}}
      {{selection}}
      ```

      Please rewrite this according to the contained instructions. Respond exclusively with the
      snippet that should replace the selection above.
      ]]

      local agent = gp.get_command_agent()
      gp.info("Implementing selection with agent: " .. agent.name)

      gp.Prompt(
        params,
        gp.Target.rewrite,
        nil, -- command will run directly without any prompting for user input
        agent.model,
        template,
        agent.system_prompt
      )
    end,
    -- }}}

    -- {{{ Translate
    Translate = function(gp, params)
      local agent = gp.get_command_agent()
      local template = "You are a Translator, please translate this into English."
      gp.Prompt(params, gp.Target.rewrite, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{  adding command which writes unit tests for the selected code
    UnitTests = function(gp, params)
      local template = [[
      I have the following code from {{filename}}:

      ``` {{filetype}}
      {{selection}}
      ```

      Please respond by writing table driven unit tests for the code above.
      ]]
      local agent = gp.get_command_agent()
      gp.Prompt(params, gp.Target.enew, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{ Explain code
    Explain = function(gp, params)

      local template = [[
      I have the following code from {{filename}}:

      ``` {{filetype}}
      {{selection}}
      ```

      Please respond by explaining the code above.
      ]]

      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.popup, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{ Proofread the text and rewrite it like a pro support
    SupportRewrite = function(gp, params)
      local template = [[

      I want you act as a proofreader. I will provide you texts and I would like you to review them
      for any spelling, grammar, or punctuation errors, and make it look from a professional
      technical support person. Please respond with only revised text and nothing else:

      {{selection}}
      ]]
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.rewrite, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{ Proofread the text and rewrite it like some tech document
    DocRewrite = function(gp, params)
      local template = [[
        I want you act as a proofreader. I will provide you texts and I would like you to review
        them for any spelling, grammar, or punctuation errors, and make it look from a piece
        professional technical document. Please respond with only revised text in markdown and
        nothing else:

        {{selection}}
      ]]
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.rewrite, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{ Rewrite it like some knowledge base article
    KBWrite = function(gp, params)
      local template = [[

        I want you to act as an Computing Technical Writer. I will give you a computing technical
        question and you need to write an artical about this topic in RedHat knowledge base style.
        This article should contains two parts: Problem description and the solution, I want you to
        explain the question in the "Problem desription" part, and provide the solution of the
        question in "Solution" part. I want you to write the topic with simply A0-level words and
        sentences, plus command examples, and explain every command in the article, avoid using the
        word like 'we' and 'you'. I want you to only reply the artical in raw markdown text without
        any format and nothing else. The artile title and some useful information is:

        {{selection}}
      ]]
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.rewrite, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}
  },
}

return
  {
    'Robitx/gp.nvim',

    enabled = function()
      return file_exists( cred_file )
    end,

    config = function()

      require('gp').setup( options )

      local wk = require("which-key")

      wk.register({
        g = {
          name = "AI辅助",
          c = { ":<C-u>'<,'>GpChatNew popup<cr>",   "Chat New"         },
          t = { ":<C-u>'<,'>GpChatPaste popup<cr>", "Chat Paste"       },

          r = { ":<C-u>'<,'>GpRewrite<cr>",         "Rewrite"          },
          a = { ":<C-u>'<,'>GpAppend<cr>",          "Append (after)"   },
          b = { ":<C-u>'<,'>GpPrepend<cr>",         "Prepend (before)" },

          i = { ":<C-u>'<,'>GpImplement<cr>",       "Implement"        },
          w = { ":<C-u>'<,'>GpSupportRewrite<cr>",  "Support Rewrtie"  },
          W = { ":<C-u>'<,'>GpDocRewrite<cr>",      "Doc Rewrite"      },
          T = { ":<C-u>'<,'>GpTranslate<cr>",       "Translate"        },
          K = { ":<C-u>'<,'>GpKBWrite<cr>",         "KB Write"         },

          n = { "<cmd>GpNextAgent<cr>",             "Next Agent"       },

        },
      }, { mode = "v", prefix = "<leader>", buffer = nil, silent = true, noremap = true, nowait = true, })

      wk.register({
        g = {
          name = "AI辅助",
          c = { "<cmd>GpChatNew popup<cr>", "New Chat" },
          t = { "<cmd>GpChatToggle popup<cr>", "Toggle Chat" },

          r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
          a = { "<cmd>GpAppend<cr>", "Append (after)" },
          b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },

          n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
        },
      }, { mode = "n", prefix = "<leader>", buffer = nil, silent = true, noremap = true, nowait = true, })

    end
  }
