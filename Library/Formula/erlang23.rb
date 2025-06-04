# Major releases of erlang should typically start out as separate formula in
# Homebrew-versions, and only be merged to master when things like couchdb and
# elixir are compatible.
class Erlang23 < Formula
  desc "Erlang Programming Language"
  homepage "http://www.erlang.org"

  head "https://github.com/erlang/otp.git"

  stable do
    url "https://github.com/erlang/otp/archive/OTP-23.3.4.20.tar.gz"
    sha256 "887859a686f3278e2a60435713ade724f97e6222cb7693a5f37c6a894ac42f8e"
  end

  resource "man" do
    url "http://www.erlang.org/download/otp_doc_man_23.3.tar.gz"
    sha256 "b890e99d3fe1b317ed083455985225550ebf74b4a8ec2af4c758e4ce6e2934ff"
  end

  resource "html" do
    url "http://www.erlang.org/download/otp_doc_html_23.3.tar.gz"
    sha256 "03d86ac3e71bb58e27d01743a9668c7a1265b573541d4111590f0f3ec334383e"
  end

  option "without-hipe", "Disable building HiPE (High-Performance Erlang); fails on various OS X systems"
  option "with-native-libs", "Enable native library compilation"
  option "with-dirty-schedulers", "Enable experimental dirty schedulers"
  option "without-docs", "Do not install documentation"

  deprecated_option "disable-hipe" => "without-hipe"
  deprecated_option "no-docs" => "without-docs"

  depends_on "autoconf" => :build
  depends_on "unixodbc" if MacOS.version >= :mavericks
  depends_on "fop" => :optional # enables building PDF docs
  # Need wxWidgets 2.8.4 or above. Tiger includes 2.5.3, 3.x needs Leopard minimum.
  depends_on "wxmac" => :recommended if MacOS.version > :tiger # for GUI apps like observer
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "openssl"
  depends_on "zlib"

  fails_with :gcc do
    build 5666
    cause "Bus error when attempting to build HiPE"
  end

  def install
    # Unset these so that building wx, kernel, compiler and
    # other modules doesn't fail with an unintelligable error.
    %w[LIBS FLAGS AFLAGS ZFLAGS].each { |k| ENV.delete("ERL_#{k}") }

    ENV["FOP"] = "#{HOMEBREW_PREFIX}/bin/fop" if build.with? "fop"

    args = %W[
      --disable-debug
      --disable-silent-rules
      --prefix=#{prefix}
      --disable-kernel-poll
      --enable-threads
      --enable-dynamic-ssl-lib
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --enable-shared-zlib
      --enable-smp-support
    ]

    args << "--enable-darwin-64bit" if MacOS.prefer_64_bit?
    args << "--enable-native-libs" if build.with? "native-libs"
    args << "--enable-dirty-schedulers" if build.with? "dirty-schedulers"
    args << "--enable-wx" if build.with? "wxmac"
    # Older Javas not supported by jinterface
    # https://github.com/mistydemeo/tigerbrew/issues/372
    args << "--without-javac" if MacOS.version < :snow_leopard
    # error: cannot compute sizeof (__int128_t, 77)
    # In /usr/include/c++/4.0.0/powerpc64-apple-darwin8/bits/stdc++.h.gch/O0g.gch & O2g.gch
    # symbol is found but configure's test for it fails, breaking the build
    args << "ac_cv_type___int128_t=no" if MacOS.version == :tiger && Hardware::CPU.family == :g5

    if MacOS.version >= :snow_leopard && MacOS::CLT.installed?
      args << "--with-dynamic-trace=dtrace"
    end

    if build.without? "hipe"
      # HiPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << "--disable-hipe"
    else
      args << "--enable-hipe"
    end

    system "./configure", *args
    system "make"
    ENV.j1 # Install is not thread-safe; can try to create folder twice and fail
    system "make", "install"

    if build.with? "docs"
      (lib/"erlang/man").install resource("man")
      doc.install resource("html")
    end
  end

  def caveats; <<-EOS.undent
    Man pages can be found in:
      #{opt_lib}/erlang/man

    Access them with `erl -man`, or add this directory to MANPATH.
    EOS
  end

  test do
    system "#{bin}/erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
  end
end
