local settings_file = os.getenv("HOME") .. '/.gp.json'

local settings = vim.json.decode(require('util').read_file(settings_file))

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

local create_providers = function(settings)
  local results = {}
  for i, a in pairs(settings) do
    results[i] = {
      endpoint = a.endpoint,
      secret = a.secret
    }
  end
  return results
end

local create_agents = function(settings)
  local results = {}
  for k, v in pairs(settings) do
    for _, a in ipairs(v.agents) do
      results[#results+1] = {
        name = a.name,
        provider = k,
        chat = a.chat,
        command = not a.chat,
        model = a.chat and { model = a.model, temperature = 1.1, top_p = 1 } or { model = a.model, temperature = 0.8, top_p = 1 },
        system_prompt = a.chat and chat_system_prompt or code_system_prompt,
      }
    end
  end
  return results
end

local options = {

  providers = create_providers(settings),

  agents = create_agents(settings),

  hooks = {
    -- {{{ InspectPlugin
    -- GpInspectPlugin provides a detailed inspection of the plugin state
    InspectPlugin = function(plugin, params)
      local bufnr = vim.api.nvim_create_buf(false, true)
      local copy = vim.deepcopy(plugin)
      local key = copy.config.openai_api_key or ""
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

      gp.Prompt( params, gp.Target.rewrite, agent, template)
    end,
    -- }}}

    -- {{{ Translate
    Translate = function(gp, params)
      local agent = gp.get_chat_agent()
      local template = [[
      You are a Translator, please translate this into English. Please respond with only revised text and nothing else:

      {{selection}}
      ]]
      gp.Prompt(params, gp.Target.rewrite, agent, template)
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
      gp.Prompt(params, gp.Target.enew, agent, template)
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
      gp.Prompt(params, gp.Target.popup, agent, template)
    end,
    -- }}}

    -- {{{ Proofread the text and rewrite it like a pro support
    SupportRewrite = function(gp, params)
      local template = [[

      I want you act as a proofreader. I will provide you texts and I would like you to review them
      for any spelling, grammar, or punctuation errors, and make it look from a professional
      technical support person. Be cool and do not use casual abbrevations "it's" or "don't". Do not
      include anything like "Here is the revised text", and respond with revised text only.

      Here is the text to proofread:

      {{selection}}

      ]]
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.rewrite, agent, template)
    end,
    -- }}}

    -- {{{ Proofread the text and rewrite it like some tech document
    DocRewrite = function(gp, params)
      local template = [[

        I want you act as a proofreader. I will provide you texts and I would like you to review
        them for any spelling, grammar, or punctuation errors, and make it look from a piece
        professional technical document. Be cool and do not use casual abbrevations "it's" or
        "don't". Do not include anything like "Here is the revised text", and respond with revised
        text only.

        Here is the text to proofread:

        {{selection}}
      ]]
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.rewrite, agent, template)
    end,
    -- }}}

    -- {{{ Rewrite it like some knowledge base article
    KBWrite = function(gp, params)
      local template = [[

        I want you to act as an Computing Technical Writer. I will give you a computing technical
        question and you need to write an artical about this topic in RedHat knowledge base style.
        This article should contains two parts: Problem description and the solution, I want you to
        explain the question in the "Problem description" part, and provide the solution of the
        question in "Solution" part. I want you to write the topic with simply A0-level words and
        sentences, plus command examples, and explain every command in the article, avoid using the
        word like 'we' and 'you'. I want you to only reply the artical in raw markdown text without
        any format and nothing else. The artile title and some useful information is:

        {{selection}}
      ]]
      local agent = gp.get_chat_agent()
      gp.Prompt(params, gp.Target.rewrite, agent, template)
    end,
    -- }}}
  },
}

return
  {
    'Robitx/gp.nvim',

    enabled = function()
      return require('util').is_file( settings_file )
    end,

    config = function()

      require('gp').setup( options )

      local wk = require("which-key")

      wk.add(
        {
          nowait = true, remap = false, mode = "v",
          { "<leader>g",  group = "AI辅助" },
          { "<leader>gK", ":<C-u>'<,'>GpKBWrite<cr>",         desc = "KB Write" },
          { "<leader>gT", ":<C-u>'<,'>GpTranslate<cr>",       desc = "Translate" },
          { "<leader>gW", ":<C-u>'<,'>GpDocRewrite<cr>",      desc = "Doc Rewrite" },
          { "<leader>gi", ":<C-u>'<,'>GpImplement<cr>",       desc = "Implement" },
          { "<leader>gt", ":<C-u>'<,'>GpChatPaste popup<cr>", desc = "Chat Paste"  },
          { "<leader>gw", ":<C-u>'<,'>GpSupportRewrite<cr>",  desc = "Support Rewrtie" },
          { "<leader>ga", ":<C-u>'<,'>GpAppend<cr>",        desc = "Append (after)",   mode = { "n", "v" } },
          { "<leader>gb", ":<C-u>'<,'>GpPrepend<cr>",       desc = "Prepend (before)", mode = { "n", "v" } },
          { "<leader>gc", ":<C-u>'<,'>GpChatNew popup<cr>", desc = "New Chat",         mode = { "n", "v" } },
          { "<leader>gn", "<cmd>GpNextAgent<cr>",           desc = "Next Agent",       mode = { "n", "v" } },
          { "<leader>gr", ":<C-u>'<,'>GpRewrite<cr>",       desc = "Rewrite",          mode = { "n", "v" } },
          { "<leader>gt", "<cmd>GpChatToggle popup<cr>",    desc = "Toggle Chat",      mode = "n" }
        }
      )

    end
  }
