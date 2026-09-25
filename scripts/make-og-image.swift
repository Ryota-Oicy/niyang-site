// OGP / Twitter Card 用の画像(1200×630)を作る。**プレースホルダー**。
//
//   swift scripts/make-og-image.swift
//
// できるもの: assets/og-image.png(全ページの og:image / twitter:image が指している)。
// 差し替える時は、同じ名前・同じ大きさ(1200×630、PNG か JPEG)の画像で上書きすればよい。
// 名前を変えるなら、各ページの <meta property="og:image"> と <meta name="twitter:image"> も直す。
// LINE・X・Instagram はプレビューをキャッシュするので、差し替えがすぐ反映されないことがある。
import AppKit

let width = 1200, height = 630
let background = NSColor(srgbRed: 0x1A / 255.0, green: 0x1A / 255.0, blue: 0x1C / 255.0, alpha: 1)
let accent = NSColor(srgbRed: 0xE8 / 255.0, green: 0x96 / 255.0, blue: 0x28 / 255.0, alpha: 1)
let muted = NSColor(srgbRed: 0xA8 / 255.0, green: 0xA8 / 255.0, blue: 0xAD / 255.0, alpha: 1)

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
background.setFill()
NSRect(x: 0, y: 0, width: width, height: height).fill()

func draw(_ text: NSAttributedString, x: CGFloat, top: CGFloat) -> CGFloat {
    let size = text.size()
    text.draw(at: NSPoint(x: x, y: CGFloat(height) - top - size.height))
    return top + size.height
}

let left: CGFloat = 96
let title = NSMutableAttributedString(string: "Dance", attributes: [
    .font: NSFont.systemFont(ofSize: 64, weight: .bold), .foregroundColor: NSColor.white,
])
title.append(NSAttributedString(string: "Now", attributes: [
    .font: NSFont.systemFont(ofSize: 64, weight: .bold), .foregroundColor: accent,
]))
var y: CGFloat = 120
y = draw(title, x: left, top: y) + 28
for line in ["Your formation.", "Your music.", "Your video."] {
    y = draw(NSAttributedString(string: line, attributes: [
        .font: NSFont.systemFont(ofSize: 58, weight: .heavy), .foregroundColor: NSColor.white,
    ]), x: left, top: y) + 2
}
y += 22
_ = draw(NSAttributedString(string: "構成を、音つきの動画でメンバーに。", attributes: [
    .font: NSFont.systemFont(ofSize: 30, weight: .medium), .foregroundColor: muted,
]), x: left, top: y)
_ = draw(NSAttributedString(string: "niyang.app/dancenow", attributes: [
    .font: NSFont.systemFont(ofSize: 24, weight: .semibold), .foregroundColor: accent,
]), x: CGFloat(width) - left - 250, top: CGFloat(height) - 80)
NSGraphicsContext.restoreGraphicsState()

let url = URL(fileURLWithPath: "assets/og-image.png")
try! rep.representation(using: .png, properties: [:])!.write(to: url)
print("wrote \(url.path)")
