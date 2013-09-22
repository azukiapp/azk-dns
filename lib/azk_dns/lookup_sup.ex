defmodule AzkDns.LookupSup do
  use Supervisor.Behaviour

  # A convenience to start the supervisor
  def start_link() do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def init([]) do
    worker = worker(AzkDns.Lookup, [], restart: :temporary)
    supervise [worker], strategy: :simple_one_for_one
  end
end
