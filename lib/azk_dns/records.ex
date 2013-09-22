defmodule AzkDns.DnsRecords do
  defmacro __using__(_opts) do
    quote do
      defrecordp :dns_header,
        id: nil, qr: 0, opcode: :query,
        aa: 0, tc: 0, rd: 0, ra: 0, pr: 0, rcode: 0

      defrecordp :dns_query, name: nil, type: nil, class: nil

      defrecordp :dns_rec, header: nil, qdlist: [], anlist: [], nslist: [], arlist: []
    end
  end
end
