class Rabbitmq < Formula
  desc "Messaging broker"
  homepage "https://www.rabbitmq.com"
  url "https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.10.7/rabbitmq-server-generic-unix-3.10.7.tar.xz"
  sha256 "fcb424deb300635086f3bf554063af654bb58f2aa4e84126f514acc00439f5c2"

  depends_on "erlang"
  skip_clean "etc"

  def install
    prefix.install Dir["*"]
  end

  def test
    assert_match "#{version}", shell_output("#{sbin}/rabbitmqctl version")
  end
end
