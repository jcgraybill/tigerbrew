class Erlang22 < Formula
  desc "Erlang Programming Language"
  homepage "http://www.erlang.org"

  keg_only "experimental formula for alternate version"

  stable do
    url "https://github.com/erlang/otp/archive/OTP-22.3.4.27.tar.gz"
      sha256 "0fb5dc388a4d6f1c7c0e250b5a44466727f35794b0566cad4190cd7c68ca5062"
end

  resource "man" do
    url "http://www.erlang.org/download/otp_doc_man_22.3.tar.gz"
    sha256 "43b6d62d9595e1dc51946d55c9528c706c5ae753876b9bf29303b7d11a7ccb16"
end

  resource "html" do
    url "http://www.erlang.org/download/otp_doc_html_22.3.tar.gz"
    sha256 "9b01c61f2898235e7f6643c66215d6419f8706c8fdd7c3e0123e68960a388c34"
end

  option "without-hipe", "Disable building HiPE (High-Performance Erlang)"
  option "with-native-libs", "Enable native library compilation"
  option "with-dirty-schedulers", "Enable experimental dirty schedulers"
  option "without-docs", "Do not install documentation"

  depends_on "automake" => :build
  depends_on "libtool" => :build

  depends_on "fop" => :optional
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "openssl"
  depends_on "wxmac" => :recommended if MacOS.version > :tiger
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
      --enable-shared-zlib
      --enable-smp-support
    ]

    args << "--enable-darwin-64bit" if MacOS.prefer_64_bit?
    args << "--enable-native-libs" if build.with? "native-libs"
    args << "--enable-dirty-schedulers" if build.with? "dirty-schedulers"
    args << "--enable-wx" if build.with? "wxmac"
    args << "--without-javac" if MacOS.version < :snow_leopard

    # error: cannot compute sizeof (__int128_t, 77)
    # In /usr/include/c++/4.0.0/powerpc64-apple-darwin8/bits/stdc++.h.gch/O0g.gch & O2g.gch
    # symbol is found but configure's test for it fails, breaking the build
    args << "ac_cv_type___int128_t=no" if MacOS.version == :tiger && Hardware::CPU.family == :g5

    if MacOS.version >= :snow_leopard && MacOS::CLT.installed?
      args << "--with-dynamic-trace=dtrace"
    end

    if build.without? "hipe"
      args << "--disable-hipe"
    else
      args << "--enable-hipe"
    end

    system "./otp_build", "autoconf"
    system "./configure", *args
    system "make"
    ENV.j1 # Install is not thread-safe; can try to create folder twice and fail
    system "make", "install"

    if build.with? "docs"
      (lib/"erlang").install resource("man").files("man")
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
