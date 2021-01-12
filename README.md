
<!-- README.md is generated from README.Rmd. Please edit that file -->

# readdat5

5ch（旧2ch）のスレを専用ブラウザで開いた時に保存されるdatファイルを読み込んで、そのスレの各レスを行に持つdata.frameを返します。

<!-- badges: start -->

<!-- badges: end -->

## インストール

以下でインストールできます。

``` r
remotes::install_github("suzuna/readdat5")
```

## 使用例

このパッケージには、関数read\_datのみが含まれます。この関数は、5chのスレを専用ブラウザで開いた時に保存されるdatファイルを読み込んで、そのスレの各レスのdata.frameを返す関数です。

``` r
read_dat(file,br_char="[br]",encoding="Shift-JIS")
```

引数は以下の通りです。

  - file: datファイルのパスです。
  - br\_char:
    レスの中に含まれる改行を、この引数で与えた文字列で表します。デフォルトは“\[br\]”です。なお、br\_charの中には、“\<”と“\>”は使用しないでください。read\_datの中で、datファイルに含まれるhtmlタグを取り除いているのですが、htmlタグだとみなされて消去されます。
  - encoding:
    datファイルのエンコーディングです。デフォルトは“Shift-JIS”です。環境によってはUTF-8を指定しないと読み込めないかもしれません。

返り値は、以下の列を持つdata.frameです。

  - dat\_id: datファイルの名前
  - thread\_title: スレのタイトル
  - res\_number: レスの番号
  - name: レスの名前欄
  - mail: レスのメール欄
  - datetime: レスの投稿日時
  - id: レスのID
  - content: レスの内容（改行はbr\_charで指定した文字で表されます）

なお、元のレスの投稿日時が“2021/1/1
01:23:45.67”のようにミリ秒以下まで存在する場合、関数を実行する前に以下を実行するとdatetimeがミリ秒以下まで表せるようになります。

``` r
options(digits.secs=2)
```

## 補足

2個以上のファイルパスを与えることはできません。2個以上のファイルパスを与えたい場合には、purrr::map\_dfrなどを用いてください。読み込みたいdatファイルが大量にある場合は、furrr::future\_map\_dfrなどを用いると、並列化によって高速に読み込めます。

``` r
file_path <- c("foo.dat","bar.dat")
map_dfr(file_path,~read_dat(file=.x,br_char="[br]",encoding="Shift-JIS"))
```
