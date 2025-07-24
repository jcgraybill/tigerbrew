class Ejabberd < Formula
  desc "XMPP application server"
  homepage "https://www.ejabberd.im"
  url "https://github.com/processone/ejabberd/archive/refs/tags/25.04.tar.gz"
  sha256 "54beae3e7729fdaab1d578a9d59046f31d8ce31c851ae5aca9532821ff22cb45"

  depends_on "autoconf" => :build
  depends_on "rebar3" => :build
  depends_on "erlang"
  depends_on "openssl3"

  # for CAPTCHA challenges
  depends_on "imagemagick" => :optional

  def install
    inreplace "Makefile.in", "DEPS:=$(sort $(shell QUIET=1 $(REBAR) $(LISTDEPS) | $(SED) -ne $(DEPSPATTERN) ))", "DEPS:=base64url cache_tab eimp epam ezlib fast_tls fast_xml fast_yaml idna jiffy jose luerl mqtree p1_acme p1_mysql p1_oauth2 p1_pgsql p1_utils pkix stringprep stun unicode_util_compat xmpp yconf"

    args = ["--prefix=#{prefix}",
            "--sysconfdir=#{etc}",
            "--localstatedir=#{var}",
            "--enable-pgsql",
            "--enable-mysql",
            "--enable-odbc",
            "--enable-pam"]

    system "./autogen.sh"
    system "./configure", *args

    system "make"
    system "make", "install"

  end
end
