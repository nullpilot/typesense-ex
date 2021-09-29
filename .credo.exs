# .credo.exs
%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["mix.exs", "lib/", "test/"]
      },
      checks: [
        {Credo.Check.Consistency.ExceptionNames, false}
      ]
    }
  ]
}
