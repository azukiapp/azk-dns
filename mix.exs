defmodule AzkDns.Mixfile do
  use Mix.Project

  def project do
    [ app: :'azk-dns',
      version: "0.0.1",
      elixir: "~> 0.10.2",
      deps: deps(Mix.env) ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  def deps(:prod) do
    []
  end

  def deps(:test) do
    deps(:prod) ++ [
      {:meck, github: "eproxus/meck", tag: "0.8.1", override: true},
      {:mock, github: "jjh42/mock"}
    ]
  end

  def deps(_) do
    deps(:prod)
  end
end
