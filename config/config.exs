import Config

config :typesense,
  base_url: {:system, "TYPESENSE_BASE_URL"},
  api_key: {:system, "TYPESENSE_API_KEY"}

env_config = "#{Mix.env()}.exs"
File.exists?("config/#{env_config}") && import_config(env_config)
