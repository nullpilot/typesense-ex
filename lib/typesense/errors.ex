defmodule Typesense.Error do
  @moduledoc false

  alias Typesense.Error.{
    HTTPError,
    MissingConfiguration,
    ObjectAlreadyExists,
    ObjectNotFound,
    ObjectUnprocessable,
    RequestMalformed,
    RequestUnauthorized,
    ServerError,
    TimeoutError
  }

  @type t ::
          HTTPError
          | MissingConfiguration
          | ObjectAlreadyExists
          | ObjectNotFound
          | ObjectUnprocessable
          | RequestMalformed
          | RequestUnauthorized
          | ServerError
          | TimeoutError
end

defmodule Typesense.Error.HTTPError do
  defexception [:message, :error]
end

defmodule Typesense.Error.MissingConfiguration do
  defexception [:message]
end

defmodule Typesense.Error.ObjectAlreadyExists do
  defexception [:message, :status]
end

defmodule Typesense.Error.ObjectNotFound do
  defexception [:message, :status]
end

defmodule Typesense.Error.ObjectUnprocessable do
  defexception [:message, :status]
end

defmodule Typesense.Error.RequestMalformed do
  defexception [:message, :status]
end

defmodule Typesense.Error.RequestUnauthorized do
  defexception [:message, :status]
end

defmodule Typesense.Error.ServerError do
  defexception [:message, :status]
end

defmodule Typesense.Error.TimeoutError do
  defexception [:message, :status]
end
