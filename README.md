# niyang.app

GitHub Pages で配信している静的サイト(ビルドなし・JS なし・解析なし)。
外部リソースは読み込まない(フォントもシステム任せ)。

## DanceNow の経路別リンク(/dancenow/go/<経路>/)

どこから来た人が App Store へ行ったかを、**App Store Connect の「キャンペーン」**(`ct=経路名`)で数えるための入口。
サイトに解析スクリプトは入れない。

| 経路 | URL | 使う所 |
|---|---|---|
| ig | https://niyang.app/dancenow/go/ig/ | Instagram のハイライト・ストーリー |
| flyer | https://niyang.app/dancenow/go/flyer/ | イベントのフライヤー・パンフ |
| studio | https://niyang.app/dancenow/go/studio/ | スタジオ掲示 |
| event | https://niyang.app/dancenow/go/event/ | 11/28 当日の会場 QR |
| x | https://niyang.app/dancenow/go/x/ | X |
| site | https://niyang.app/dancenow/go/site/ | 製品ページ(/dancenow/)の App Store ボタン |

### App ID と provider token を入れる(1か所)

1. `dancenow/go/_config.txt` の `APP_ID=` と `PROVIDER_TOKEN=` に値を入れる
   (App ID は App Store Connect の「App 情報」→ Apple ID、provider token は「App 分析」→ キャンペーン)。
2. `python3 scripts/build-go-links.py` を実行する(6つのページが作り直される)。
3. コミットして push。

**値が空の間は、各ページは App Store へ転送せず「準備中」を出す。** 転送先は
`https://apps.apple.com/app/id<APP_ID>?pt=<PROVIDER_TOKEN>&ct=<経路名>&mt=8`。
予約注文から本公開に変わっても App の URL(id)は変わらないので、そのままでよい。

### QR コード(dancenow/go/qr/<経路>.png)

- **QR が指すのは niyang.app の固定 URL で、App Store の URL ではない。** 転送先が変わっても刷り直さなくてよい。
- 1170px 角・誤り訂正 M・周囲に余白つき。印刷で 10cm 角まで拡大しても粗くならない。
- 作り直す(経路を足した時など): `swift scripts/make-go-qr.swift`

### 経路を足す

`scripts/build-go-links.py` の `ROUTES` と `scripts/make-go-qr.swift` の `routes` に足し、両方を実行する。

## OGP 画像(assets/og-image.png)

全ページの `og:image` / `twitter:image` が指している 1200×630 の画像(いまはプレースホルダー)。
差し替えは同じ名前・同じ大きさの画像で上書きするか、`swift scripts/make-og-image.swift` で作り直す。
LINE・X・Instagram はプレビューをキャッシュするので、すぐには反映されないことがある。

## ガイド記事(/dancenow/guide/)— いまは下書き

| 記事 | URL |
|---|---|
| 構成(フォーメーション)の作り方 — 基本の手順 | /dancenow/guide/formation-basics/ |
| 10人前後のフォーメーション — 立ち位置・移動・ハケ(袖) | /dancenow/guide/ten-dancers/ |
| 複数曲をつないだショーの構成の合わせ方 | /dancenow/guide/multi-song-show/ |

**3本とも`<meta name="robots" content="noindex">`付きの下書きで、どのページからもリンクしていない**
(URL を知っている人だけが読める)。末尾の「この手順をアプリでやるなら」から /dancenow/go/site/ へ飛ぶ。
書くときの決まり: 誇張・根拠のない数字・他アプリの批判を書かない。競合の名前を出さない。

### 承認して公開する手順

1. 記事を読んで直す(直したら「承認した版」としてコミット)。
2. その記事の`<head>`から、`<meta name="robots" content="noindex">`の行と、その上の「下書き」のコメントを消す。
3. 必要なら、製品ページ(dancenow/index.html)やサポートページからリンクを張る
   (**下書きの間は張らない**)。
4. コミットして push。検索に載るまでは数日〜数週間かかる
   (急ぐなら Google Search Console で URL の登録をリクエストする)。
