defmodule AzkDns.Lookup.Test do
  use AzkDns.Case, async: false

  alias AzkDns.Options
  alias AzkDns.Lookup

  test "reply with nxdomain if domain can not found" do
    opts   = Options.new("127.0.0.1", "dev")
    domain = "test.dev.io"
    mocks  = mock_send(message(domain, [], [rcode: 3]))

    with_mock :gen_udp, [:unstick], mocks do
      {:ok, _} = Lookup.lookup(:socket, :ip, :port, message(domain, []), opts)
      assert_receive :sended
      assert called :gen_udp.send(:socket, :ip, :port, :_)
    end
  end

  test "reply with ip if domain founded" do
    opts   = Options.new("127.0.0.1", "dev")
    Enum.each(["test.dev", "dev"], fn (domain) ->
      rr     = :inet_dns.make_rr(
        type: :a, domain: '#{domain}', class: :in,
        ttl: 300, data: {127, 0, 0, 1}
      )
      header = [qr: true, aa: true, rd: true, ra: true]
      mocks  = mock_send(message(domain, [rr], header))

      with_mock :gen_udp, [:unstick], mocks do
        {:ok, _} = Lookup.lookup(:socket, :ip, :port, message(domain, []), opts)
        assert_receive :sended
        assert called :gen_udp.send(:socket, :ip, :port, :_)
      end
    end)
  end

  def mock_send(msg) do
    pid = self
    [send: fn :socket, :ip, :port, data ->
      case data == msg do
        false -> pid <- :error
        true  -> pid <- :sended
      end
    end]
  end

  def message(domain, anlist, header // []) do
    query  = {:dns_query, '#{domain}', :a, :in}
    header = Keyword.merge([opcode: :query, rd: true, rcode: 0], header)
    :inet_dns.encode(:inet_dns.make_msg(
      header: :inet_dns.make_header(header),
      qdlist: [query],
      anlist: anlist
    ))
  end
end
