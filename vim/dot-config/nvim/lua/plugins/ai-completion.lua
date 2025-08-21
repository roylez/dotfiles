return {
  'milanglacier/minuet-ai.nvim',
  enabled = function() return os.getenv("OPENROUTER_API_KEY") end,
  opts = {
    provider = "openai_compatible",
    request_timeout = 2.5,
    n_completions = 1,
    virtualtext = {
      auto_trigger_ft = { 'elixir' },
      keymap = {
        accept_line = '<C-y>',
        accept = '<A-y>',
      },
    },
    provider_options = {
      openai_compatible = {
        name = "OpenRouter",
        end_point = "https://openrouter.ai/api/v1/chat/completions",
        api_key = "OPENROUTER_API_KEY", -- point to your environment variable name
        model = "qwen/qwen3-coder",
        -- model = "google/gemini-2.5-flash-lite",
        -- model = "openai/gpt-4o-mini",
        stream = true,
        optional = {
          max_tokens = 56,
          top_p = 0.95,
          provider = { sort = "throughput" },
          reasoning = { effort = 'minimal' },
        },
      },
    },
  }
}
