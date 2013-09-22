defmodule AzkDnsTest do
  use AzkDns.Case
  use AzkDns.DnsRecords

  setup_all do
    dns_server = "udp://localhost:8053"
    URI.Info[host: host, port: port] = URI.parse(dns_server)
    {:ok, host} = :inet.ip('#{host}')

    {:ok, server: [{host, port}]}
  end

  test "simple query to server", var do
    {:ok, dns_rec(anlist: anlist)} = :inet_res.nnslookup('dev.azk.io', :in, :a, var[:server])
    refute anlist == []
    {:ok, dns_rec(anlist: anlist)} = :inet_res.nnslookup('dev.azk', :in, :a, var[:server])
    refute anlist == []
  end
end
