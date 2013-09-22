defmodule AzkDns do
  use GenServer.Behaviour

  alias AzkDns.Config
  alias AzkDns.Lookup
  alias AzkDns.Options

  defrecord State, socket: nil, options: []

  def pp(value), do: IO.inspect(value)

  # Supervisor API
  @spec start_link :: {:ok, pid}
  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  # GenServer API
  def init([]) do
    {ip, port, resvto, domains} = get_opts
    opts = [:binary | [active: true, ip: ip]]
    {:ok, socket}  = :gen_udp.open(port, opts)
    {:ok, State.new(socket: socket, options: Options.new(resvto, domains))}
  end

  def handle_info({:udp, socket, ip, port, bin}, State[options: options] = state) do
    Lookup.lookup(socket, ip, port, bin, options)
    {:noreply, state}
  end

  def terminate(reason, State[socket: socket]) do
    :gen_udp.close(socket)
    :ok
  end

  defp get_opts do
    resvto  = Config.get(:azkdns_resvto)
    domains = Config.get(:azkdns_domains)
    URI.Info[scheme: "udp", host: host, port: port] = URI.parse(Config.get(:azkdns_address))
    {:ok, ip} = :inet.ip('#{host}')
    {ip, port, resvto, domains}
  end
end
