defmodule Typesense.Middleware.FormatResponse do
  @moduledoc """
  This module unwraps the Tesla `{:ok, %Tesla.Env}` response to an `{:ok, content}` or `{:error, error}` tuple respectively.

  Note that `error` itself is currently a tuple in the form of `{status :: Atom, message :: String.t}` and may be replaced by custom error objects at a later point.
  """

  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, _options) do
    env
    |> Tesla.run(next)
    |> handle_response()
  end

  def handle_response({:error, error}), do: {:error, error}

  def handle_response({:ok, %{status: status, body: body}}) when status >= 200 and status < 300 do
    {:ok, body}
  end

  def handle_response({:ok, %{status: status}}) do
    message = "Request failed with HTTP code #{status}"
    error_response(status, message)
  end

  def handle_response({:ok, %{status: status, body: %{message: server_message}}}) do
    message = "Request failed with HTTP code #{status} | Server said: #{server_message}"
    error_response(status, message)
  end

  defp error_response(status, message) when status >= 500 and status <= 599,
    do: {:error, {:server_error, message}}

  defp error_response(400, message), do: {:error, {:bad_request, message}}
  defp error_response(401, message), do: {:error, {:unauthorized, message}}
  defp error_response(404, message), do: {:error, {:not_found, message}}
  defp error_response(409, message), do: {:error, {:conflict, message}}
  defp error_response(422, message), do: {:error, {:unprocessable_entity, message}}
end
