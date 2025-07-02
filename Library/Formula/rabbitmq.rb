class Rabbitmq < Formula
  desc "Messaging broker"
  homepage "https://www.rabbitmq.com"
  url "https://github.com/rabbitmq/rabbitmq-server/archive/refs/tags/v3.10.7.tar.gz"
  sha256 "9557f9bc8c0bd21408738def2d8137a76aa044948522493c8757a3a7d8e27fec"
  head "https://github.com/rabbitmq/rabbitmq-server.git"

  depends_on "simplejson" => :python
  depends_on "elixir" => :build
  depends_on "erlang"

  def install
    system "PREFIX=#{prefix}", "gmake"
    system "PREFIX=#{prefix}", "gmake", "install"
  end
end
