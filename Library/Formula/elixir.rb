class Erlang23Requirement < Requirement
  fatal true
  env :userpaths
  default_formula "erlang"

  satisfy do
    erl = which("erl")
    next unless erl
    `#{erl} -noshell -eval 'io:fwrite("~s~n", [erlang:system_info(otp_release)]).' -s erlang halt | grep -q '^2[34567]'`
    $?.exitstatus == 0
  end

  def message; <<-EOS.undent
    Erlang 23+ is required to install.

    You can install this with:
      brew install erlang

    Or you can use an official installer from:
      http://www.erlang.org/
    EOS
  end
end

class Elixir < Formula
  desc "Functional metaprogramming aware language built on Erlang VM"
  homepage "http://elixir-lang.org/"
  url "https://github.com/elixir-lang/elixir/archive/v1.14.5.tar.gz"
  sha256 "2ea249566c67e57f8365ecdcd0efd9b6c375f57609b3ac2de326488ac37c8ebd"

  head "https://github.com/elixir-lang/elixir.git"

  depends_on Erlang23Requirement
  # make: *** virtual memory exhausted.  Stop.
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
