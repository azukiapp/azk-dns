defmodule AzkDns.Lookup do

  use AzkDns.DnsRecords

  def start_link(socket, ip, port, msg, opts) do
    :proc_lib.start_link(__MODULE__, :init, [self, socket, ip, port, msg, opts])
  end

  def init(parent, socket, ip, port, msg, opts) do
    :proc_lib.init_ack(parent, {:ok, self})
    :gen_udp.send(socket, ip, port, make_response(msg, opts))
  end

  def lookup(socket, ip, port, msg, opts) do
    :supervisor.start_child(AzkDns.LookupSup, [socket, ip, port, msg, opts])
  end

  defp make_response(msg, opts) do
    dns_rec(header: header, qdlist: [dns_query(name: name, type: :a)]) = msg = parse_msg(msg)
    :inet_dns.encode(case opts.lookup("#{name}") do
      {:ok, ip} ->
        dns_rec(msg, header: dns_header(header,
          qr: true, aa: true, rd: true, ra: true
        ), anlist: [:inet_dns.make_rr(
          type: :a, domain: name, class: :in,
          ttl: 300, data: ip
        )])
      {:error, _} ->
        dns_rec(msg, header: dns_header(header, rcode: 3))
    end)
  end

  defp parse_msg(msg) when is_binary(msg) do
    {:ok, dns_rec() = msg} = :inet_dns.decode(msg)
    msg
  end

  defp pp(value), do: IO.inspect(value)
end
