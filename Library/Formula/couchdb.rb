class Couchdb < Formula
  desc "CouchDB is a document database server"
  homepage "https://couchdb.apache.org/"
  url "https://dlcdn.apache.org/couchdb/source/3.2.3/apache-couchdb-3.2.3.tar.gz"
  sha256 "c830ea9014177eed9989b160ea92dde79f724519b8e677c4d2e8fca22836e85c"

  depends_on "spidermonkey"
  depends_on "erlang"
  depends_on "icu4c"
  depends_on "openssl3"
  depends_on "rebar" => :build
  depends_on "rebar3" => :build
  depends_on "help2man" => :build
  
  def install
    system "./configure"
    system "make", "release"
    inreplace "rel/couchdb/etc/default.ini", "./data", "#{var}/couchdb/data"
    prefix.install Dir["rel/couchdb/*"]
  end
end
