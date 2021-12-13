# Sqlite Ext

This is _extended_ sqlite build with icu4c and some other features. This makes sqlite_ext is better and faster than regular homebrew's sqlite.

*Warning!* This breaks some important packages from brew that relies on legacy sqlite apis. For example: this breaks python3 and aws-cli.

For more information check compile options in [sqlite_ext.rb](https://github.com/mecurc/homebrew-sqlite-ext/blob/main/sqlite_ext.rb)


### Roadmap

- write better docs (probably never)
