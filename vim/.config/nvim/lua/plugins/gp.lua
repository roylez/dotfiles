function file_exists(name)
  local f = io.open(name, "r")
  return f ~= nil and io.close(f)
end

local cred_file = os.getenv("HOME") .. '/.gpt'

local options = {
  openai_api_key = { "cat", cred_file },

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
      local template = "Having following from {{filename}}:\n\n"
      .. "```{{filetype}}\n{{selection}}\n```\n\n"
      .. "Please rewrite this according to the contained instructions."
      .. "\n\nRespond exclusively with the snippet that should replace the selection above."

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

    -- your own functions can go here, see README for more examples like
    -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

    -- -- example of making :%GpChatNew a dedicated command which
    -- -- opens new chat with the entire current buffer as a context
    -- BufferChatNew = function(gp, _)
    -- 	-- call GpChatNew command in range mode on whole buffer
    -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
    -- end,

    -- -- example of adding command which opens new chat dedicated for translation
    -- Translator = function(gp, params)
    -- 	local agent = gp.get_command_agent()
    -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
    -- 	gp.cmd.ChatNew(params, agent.model, chat_system_prompt)
    -- end,

    -- {{{  adding command which writes unit tests for the selected code
    UnitTests = function(gp, params)
    	local template = "I have the following code from {{filename}}:\n\n"
    		.. "```{{filetype}}\n{{selection}}\n```\n\n"
    		.. "Please respond by writing table driven unit tests for the code above."
    	local agent = gp.get_command_agent()
    	gp.Prompt(params, gp.Target.enew, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{ Explain code
    Explain = function(gp, params)
    	local template = "I have the following code from {{filename}}:\n\n"
    		.. "```{{filetype}}\n{{selection}}\n```\n\n"
    		.. "Please respond by explaining the code above."
    	local agent = gp.get_chat_agent()
    	gp.Prompt(params, gp.Target.popup, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{ Proofread the text and rewrite it like a pro support
    SupportRewrite = function(gp, params)
      local template = "I want you act as a proofreader. I will provide you texts and I would like you to review them for any spelling, grammar, or punctuation errors, and make it look from a professional technical support person. Please respond with only revised text and nothing else:\n\n{{selection}}"
      local agent = gp.get_chat_agent()
    	gp.Prompt(params, gp.Target.rewrite, nil, agent.model, template, agent.system_prompt)
    end,
    -- }}}

    -- {{{ Proofread the text and rewrite it like some tech document
    DocRewrite = function(gp, params)
      local template = "I want you act as a proofreader. I will provide you texts and I would like you to review them for any spelling, grammar, or punctuation errors, and make it look from a piece professional technical document. Please respond with only revised text in markdown and nothing else:\n\n{{selection}}"
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

      local actions = {
        [ "SupportRewrite" ] = "'<,'>GpSupportRewrite",
        [ "DocRewrite" ]     = "'<,'>GpDocRewrite",
        [ "Explain" ]        = "'<,'>GpExplain",
        [ "Implement" ]      = "'<,'>GpImplement",
        [ "UnitTests" ]      = "'<,'>GpUnitTests",
      }

      local menu = require('util').create_menu("GPT actions", actions)

      vim.keymap.set({'n', 'v'}, '<leader>g', menu, { silent = true, desc = 'GPT...' })

    end

  }
