defmodule AzkDns.App do
  use Application.Behaviour

  def start do
    Application.Behaviour.start(:'azk-dns')
  end

  def start(_type, _args) do
    AzkDns.Supervisor.start_link
  end
end
