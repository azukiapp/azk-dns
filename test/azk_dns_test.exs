defmodule AzkDnsTest do
  use AzkDns.Case

  test "" do
    #dns_server = "tcp://localhost:8053"
    dns_server = "tcp://8.8.8.8:53"
    URI.Info[host: host, port: port] = URI.parse(dns_server)
    {:ok, host} = :inet.ip('#{host}')
    #{:ok, pid} = AzkDns.start_link
    #pp :inet_res.nslookup('www.azukiapp.com', :in, :a)
    #pp :inet_res.nnslookup('azk.io', :in, :a, [{host, port}])
    pp :inet_res.nnslookup('dev.azk.io', :in, :a, [{host, port}])
    pp :inet_res.nnslookup('dev.azk', :in, :a, [{host, port}])
    pp :inet_res.nnslookup('example.com', :in, :a, [{host, port}])
    #pp :inet_res.nnslookup('blog.dev.azk.io', :in, :a, [{host, port}])
  end
end
