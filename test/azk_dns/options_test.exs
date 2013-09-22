defmodule AzkDns.Options.Test do
  use AzkDns.Case
  alias AzkDns.Options, as: Opts

  test "parse a ip address" do
    opts = Opts.new("127.0.0.1")
    assert {127, 0, 0, 1} == opts.ip

    opts = opts.ip {127, 0, 0, 1}
    assert {127, 0, 0, 1} == opts.ip
  end

  test "lookup domain in domains pattern" do
    opts = Opts.new({127, 0, 0, 1})
    assert {:ok, opts.ip} == opts.lookup "dev.azk.io"
    assert {:ok, opts.ip} == opts.lookup "blog.dev.azk.io"

    {:error, msg} = opts.lookup "google.com"
    assert "google.com not found in dev.azk.io" == msg

    opts = opts.domains "dev"
    assert {:ok, opts.ip} == opts.lookup "dev"
    assert {:ok, opts.ip} == opts.lookup "blog.dev"
  end
end
