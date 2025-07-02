class Elixir < Formula
  desc "Functional metaprogramming aware language built on Erlang VM"
  homepage "http://elixir-lang.org/"
  url "https://github.com/elixir-lang/elixir/archive/v1.13.4.tar.gz"
  sha256 "95daf2dd3052e6ca7d4d849457eaaba09de52d65ca38d6933c65bc1cdf6b8579"

  head "https://github.com/elixir-lang/elixir.git"

  depends_on 'erlang'
  depends_on "make" => :build

  def install
    # The module Mix.State was given as a child to a supervisor but it does not exist.
    ENV.deparallelize
    system "gmake"
    bin.install Dir["bin/*"] - Dir["bin/*.{bat,ps1}"]

    Dir.glob("lib/*/ebin") do |path|
      app = File.basename(File.dirname(path))
      (lib/app).install path
    end
  end

  test do
    system "#{bin}/elixir", "-v"
  end
end
