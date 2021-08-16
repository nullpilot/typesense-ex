# .credo.exs
%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["mix.exs", "lib/", "test/"]
      }
    }
  ]
}
