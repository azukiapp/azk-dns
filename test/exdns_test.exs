defmodule AzkDnsTest do
  use ExUnit.Case

  def pp(value), do: IO.inspect(value)

  #setup_all do
    #options = [
      #bind: "upd://localhost:8053",
      #address: [
        #{ %r/^.*\.dev\.azk\.io$/, "192.168.50.1" }
      #]
    #]
    #{:ok, pid} = AzkDns.start_link(options)
  #end

  test "ha" do
    dns_server = "tcp://localhost:8053"
    #dns_server = "tcp://8.8.8.8:53"
    URI.Info[host: host, port: port] = URI.parse(dns_server)
    {:ok, host} = :inet.ip('#{host}')
    {:ok, pid} = AzkDns.start_link
    pp :inet_res.nslookup('www.azukiapp.com', :in, :a)
    pp :inet_res.nnslookup('azk.io', :in, :a, [{host, port}])
    pp :inet_res.nnslookup('dev.azk.io', :in, :a, [{host, port}])
    pp :inet_res.nnslookup('blog.dev.azk.io', :in, :a, [{host, port}])
  end
end
