defmodule AzkDns do
  use GenServer.Behaviour

  defrecord State, socket: nil, addresses: []

  defrecordp :dns_header, id: nil, qr: false, opcode: :query, aa: false, tc: false, rd: false, ra: false, pr: false, rcode: 0
  defrecordp :dns_rec, header: nil, qdlist: [], anlist: [], nslist: [], arlist: []
  defrecordp :dns_query, name: nil, type: nil, class: nil

  def pp(value), do: IO.inspect(value)

  # Supervisor API
  @spec start_link :: {:ok, pid}
  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  # GenServer API
  def init([]) do
    opts = [:binary | [active: true]]
    {:ok, socket}  = :gen_udp.open(8053, opts)
    {:ok, address} = :inet.ip('192.168.50.4')
    addresses = [
      { %r/^.*\.dev\.azk\.io$/, address }
    ]
    {:ok, State.new(socket: socket, addresses: addresses)}
  end

  def handle_info(udpmsg, State[addresses: addresses] = state) do
    answer_query(udpmsg, addresses)
    {:noreply, state}
  end

  defp answer_query({:udp, socket, ip, port, bin}, addresses) do
    {:ok, query}   = :inet_dns.decode(bin)
    :gen_udp.send(socket, ip, port, make_response(addresses, query))
  end

  defp make_response(addresses, dns_rec(qdlist: qdlist) = query) do
    pp qdlist
    qdlist = filter_qdlist(addresses, qdlist)
    pp qdlist
    alist  = lc {dns_query(name: name, type: :a), ip} inlist qdlist do
      :inet_dns.make_rr(
        type: :a, domain: name, class: :in,
        ttl: 300, data: ip
      )
    end
    query = dns_rec(query, anlist: alist)
    :inet_dns.encode(query)
  end

  defp filter_qdlist(addresses, qdlist), do: filter_qdlist(addresses, qdlist, [])
  defp filter_qdlist(addresses, [], acc), do: acc
  defp filter_qdlist(addresses, [dns_query(name: name) = query | qdlist], acc) do
    find = fn {rex, _} -> Regex.match?(rex, name) end
    filter_qdlist(addresses, qdlist, case Enum.find(addresses, find) do
      {_, ip} ->
        acc ++ [{query, ip}]
      nil -> acc
    end)
  end
end
