defmodule Typesense.Healthcheck do
  @moduledoc """
  Internal module to store and access node health data.
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def is_viable(node_url, healthcheck_interval) do
    valid_before = System.system_time(:millisecond) - healthcheck_interval

    case :ets.lookup(__MODULE__, node_url) do
      [] -> true
      [{_node_url, true, _last_access}] -> true
      [{_node_url, false, last_access}] when last_access < valid_before -> true
      _ -> false
    end
  end

  def pass_check(node_url), do: GenServer.call(__MODULE__, {:pass, node_url})

  def fail_check(node_url), do: GenServer.call(__MODULE__, {:fail, node_url})

  @impl true
  def init(_) do
    :ets.new(__MODULE__, [:set, :protected, :named_table])
    {:ok, nil}
  end

  @impl true
  def handle_call({:pass, node_url}, _from, _state) do
    :ets.insert(__MODULE__, {node_url, true, System.system_time(:millisecond)})
    {:reply, :ok, nil}
  end

  @impl true
  def handle_call({:fail, node_url}, _from, _state) do
    :ets.insert(__MODULE__, {node_url, false, System.system_time(:millisecond)})
    {:reply, :ok, nil}
  end
end
