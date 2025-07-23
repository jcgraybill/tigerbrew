class Rabbitmq < Formula
  desc "Messaging broker"
  homepage "https://www.rabbitmq.com"
  url "https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.10.7/rabbitmq-server-generic-unix-3.10.7.tar.xz"
  sha256 "fcb424deb300635086f3bf554063af654bb58f2aa4e84126f514acc00439f5c2"

  depends_on "erlang"

  def install
    prefix.install Dir["*"]
    prefix.install "etc"
  end
end
