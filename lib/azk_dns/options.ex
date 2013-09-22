defmodule AzkDns.Options do

  @fields [ip: nil, domains: "", pattern: nil]
  Record.deffunctions(@fields, __ENV__)
  Record.import __MODULE__, as: :opts

  def new(ip, domains // "dev.azk.io") do
    opts().domains(domains).ip(ip)
  end

  defoverridable ip: 2
  def ip(address, opts() = opts) when is_bitstring(address) do
    {:ok, ip} = :inet.ip('#{address}')
    super(ip, opts)
  end

  def ip(ip, opts() = opts) do
    super(ip, opts)
  end

  defoverridable domains: 2
  def domains(value, opts() = opts) do
    opts(opts, domains: value, pattern: make_pattern(value))
  end

  def lookup(address, opts(ip: ip, pattern: pattern, domains: domains)) do
    case Regex.match?(pattern, address) do
      true -> {:ok, ip}
      _ -> {:error, "#{address} not found in #{domains}"}
    end
  end

  defp make_pattern(domains) when is_bitstring(domains) do
    domains = Enum.map(String.split(domains, ","), String.strip(&1))
    domains = Enum.join(domains, "|")
    %r/^(.*\.?(#{domains}))$/gi
  end
end
