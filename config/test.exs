import Config

config :typesense,
  api_key: "xyz",
  nearest_node: [
    protocol: 'http',
    host: 'localhost',
    port: '8108'
  ],
  nodes: [
    [
      protocol: 'http',
      host: 'localhost',
      port: '8308'
    ],
    [
      protocol: 'http',
      host: 'localhost',
      port: '8208'
    ]
  ],
  api_key_in_query: false,
  max_retries: 10,
  retry_interval: 1_000,
  healthcheck_interval: 2_000,
  pool_options: [
    timeout: 2_000,
    max_connections: 3
  ]
