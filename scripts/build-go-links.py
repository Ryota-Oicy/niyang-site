#!/usr/bin/env python3
"""DanceNow の経路別リンク(/dancenow/go/<経路>/index.html)を、dancenow/go/_config.txt から作り直す。

    python3 scripts/build-go-links.py

- 各ページは `<meta http-equiv="refresh">` で App Store へ即時転送し、転送されない時用の手動リンクを置く。
- 設定が空の間は転送しない(「準備中」のページを出す)。
- 解析スクリプトは入れない。計測は App Store Connect の「キャンペーン」(ct=経路名)で行う。
- 経路を足す時は ROUTES に足して、QR も作り直す(swift scripts/make-go-qr.swift)。
"""
import html
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CONFIG = os.path.join(ROOT, "dancenow", "go", "_config.txt")

# 経路名(App Store Connect のキャンペーン名 ct= にそのまま入る)と、人が読む説明。
ROUTES = {
    "ig": "Instagram",
    "flyer": "イベントのフライヤー・パンフ",
    "studio": "スタジオ掲示",
    "event": "11/28 当日の会場 QR",
    "x": "X",
    "site": "製品ページのボタン",
}


def read_config():
    values = {}
    for line in open(CONFIG, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values.get("APP_ID", ""), values.get("PROVIDER_TOKEN", "")


HEAD = """<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex">
  <title>DanceNow — niyang.app</title>
{refresh}  <meta property="og:type" content="website">
  <meta property="og:site_name" content="niyang.app">
  <meta property="og:title" content="DanceNow — Your formation. Your music. Your video.">
  <meta property="og:description" content="構成を、音つきの動画でメンバーに。">
  <meta property="og:url" content="https://niyang.app/dancenow/go/{route}/">
  <meta property="og:image" content="https://niyang.app/assets/og-image.png">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:image" content="https://niyang.app/assets/og-image.png">
  <link rel="stylesheet" href="/assets/style.css">
</head>
<body>
  <!-- このファイルは scripts/build-go-links.py が作る。手で直さない(経路: {label})。 -->
  <main>
"""

READY = """    <p class="app"><strong>Dance<span style="color: var(--accent)">Now</span></strong></p>
    <p>App Store へ移動しています…</p>
    <p><a class="button" href="{url}">App Store を開く</a></p>
    <p class="muted">移動しない時は、上のボタンを押してください。 / If nothing happens, tap the button.</p>
"""

PENDING = """    <p class="app"><strong>Dance<span style="color: var(--accent)">Now</span></strong></p>
    <p>DanceNow は App Store で公開の準備中です。</p>
    <p><a class="button" href="/dancenow/">DanceNow について</a></p>
    <p class="muted">DanceNow is coming soon to the App Store.</p>
"""

TAIL = """  </main>
</body>
</html>
"""


def main():
    app_id, token = read_config()
    ready = bool(app_id) and bool(token)
    for route, label in ROUTES.items():
        folder = os.path.join(ROOT, "dancenow", "go", route)
        os.makedirs(folder, exist_ok=True)
        if ready:
            url = f"https://apps.apple.com/app/id{app_id}?pt={token}&ct={route}&mt=8"
            escaped = html.escape(url, quote=True)
            refresh = f'  <meta http-equiv="refresh" content="0; url={escaped}">\n'
            body = READY.format(url=escaped)
        else:
            refresh = ""
            body = PENDING
        page = HEAD.format(refresh=refresh, route=route, label=label) + body + TAIL
        with open(os.path.join(folder, "index.html"), "w", encoding="utf-8") as f:
            f.write(page)
        print(f"{route}: {'App Store へ転送' if ready else '準備中(設定が空)'}")


if __name__ == "__main__":
    main()
