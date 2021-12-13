class SqliteExt < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2021/sqlite-autoconf-3370000.tar.gz"
  version "3.37.0"
  license "blessing"

  sha256 "731a4651d4d4b36fc7d21db586b2de4dd00af31fd54fb5a9a4b7f492057479f7"

  livecheck do
    url "https://sqlite.org/news.html"
    regex(%r{v?(\d+(?:\.\d+)+)</h3>}i)
  end

  depends_on "readline"
  depends_on "icu4c"

  uses_from_macos "zlib"

  def install
    # Optimize for speed
    ENV.append "CPPFLAGS", "-O2"

    # Sqlite recomendations at https://sqlite.org/compile.html
    ENV.append "CPPFLAGS", "-DSQLITE_DQS=0"
    ENV.append "CPPFLAGS", "-DSQLITE_DEFAULT_MEMSTATUS=0"
    ENV.append "CPPFLAGS", "-DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_LIKE_DOESNT_MATCH_BLOBS"
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_EXPR_DEPTH=0"
    ENV.append "CPPFLAGS", "-DSQLITE_OMIT_DEPRECATED"
    ENV.append "CPPFLAGS", "-DSQLITE_USE_ALLOCA"
    ENV.append "CPPFLAGS", "-DSQLITE_OMIT_AUTOINIT"

    # Extended options
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_COLUMN_METADATA"
    ENV.append "CPPFLAGS", "-DSQLITE_DISABLE_DIRSYNC"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_RTREE"
    ENV.append "CPPFLAGS", "-DSQLITE_SECURE_DELETE"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_UNLOCK_NOTIFY"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_DBSTAT_VTAB"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_JSON1"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_FTS5"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_GEOPOLY"
    ENV.append "CPPFLAGS", "-DSQLITE_USE_URI"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_LOAD_EXTENSION"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_STAT4"
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_UPDATE_DELETE_LIMIT"
    ENV.append "CPPFLAGS", "-DSQLITE_SOUNDEX"
    ENV.append "CPPFLAGS", "-DSQLITE_DEFAULT_FOREIGN_KEYS=1"
    ENV.append "CPPFLAGS", "-DSQLITE_TEMP_STORE=3"
    ENV.append "CPPFLAGS", "-DSQLITE_MAX_VARIABLE_NUMBER=250000"
    ENV.append "CPPFLAGS", "-DSQLITE_TRACE_SIZE_LIMIT=32"
    ENV.append "CPPFLAGS", "-DSQLITE_DEFAULT_CACHE_SIZE=-16000"
    ENV.append "CPPFLAGS", "-DSQLITE_THREADSAFE=2"

    # This breaks pysqlite3
    ENV.append "CPPFLAGS", "-DSQLITE_OMIT_PROGRESS_CALLBACK"
    ENV.append "CPPFLAGS", "-DSQLITE_OMIT_SHARED_CACHE"
    ENV.append "CPPFLAGS", "-DSQLITE_OMIT_DEPRECATED"

    # Etc
    ENV.append "CPPFLAGS", "-DSQLITE_OMIT_GET_TABLE"
    ENV.append "CPPFLAGS", "-DSQLITE_OMIT_TCL_VARIABLE"

    icu4c = Formula["icu4c"]
    icu4c_ldflags = `#{icu4c.opt_bin}/icu-config --ldflags`.tr("\n", " ")
    icu4c_cppflags = `#{icu4c.opt_bin}/icu-config --cppflags`.tr("\n", " ")

    ENV.append "LDFLAGS", icu4c_ldflags
    ENV.append "CPPFLAGS", icu4c_cppflags
    ENV.append "CPPFLAGS", "-DSQLITE_ENABLE_ICU"

    args = %W[
      --prefix=#{prefix}
      --program-suffix=_ext
      --disable-dependency-tracking
      --disable-editline
      --disable-fts3
      --disable-fts4
      --enable-dynamic-extensions
      --enable-readline
      --enable-session
      --enable-threadsafe
      --enable-static
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    sql_path = testpath/"school.sql"
    sql_path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values
        ('Я_Последний', 14),
        ('А_Первый', 12),
        ('Б_Второй', 13);
      select name from students order by name;
    EOS

    sqliterc_path = testpath/".sqliterc"
    sqliterc_path.write nil

    names = shell_output("#{bin}/sqlite3_ext -init #{sqliterc_path} < #{sql_path}").strip.split("\n")
    assert_equal ['А_Первый', 'Б_Второй', 'Я_Последний'], names
  end
end
