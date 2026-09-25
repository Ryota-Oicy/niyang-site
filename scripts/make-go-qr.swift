// 経路別リンクの QR コード(印刷用 PNG)を dancenow/go/qr/ に作る。
//
//   swift scripts/make-go-qr.swift
//
// **QR が指すのは niyang.app の固定 URL(/dancenow/go/<経路>/)で、App Store の URL ではない。**
// 予約注文 → 本公開で転送先が変わっても、印刷物を刷り直さなくてよい(転送先は _config.txt で変える)。
//
// 仕様: 誤り訂正 M(汚れ・折れに少し強い)、モジュールを整数倍に拡大して 1 辺 1200px 前後、
// 周囲に 4 モジュールの余白(読み取りに必要な quiet zone)。白地に黒。
// 1200px は 印刷で 10cm 角(300dpi なら約 1181px)まで拡大しても粗くならない大きさ。
import AppKit
import CoreImage

let routes = ["ig", "flyer", "studio", "event", "x", "site"]
let outputFolder = URL(fileURLWithPath: "dancenow/go/qr", isDirectory: true)
try? FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)

for route in routes {
    let url = "https://niyang.app/dancenow/go/\(route)/"
    let filter = CIFilter(name: "CIQRCodeGenerator")!
    filter.setValue(Data(url.utf8), forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")
    // CoreImage の出力は 1 モジュール = 1px(周囲に 1 モジュールの余白つき)。
    let qr = filter.outputImage!
    let modules = Int(qr.extent.width)
    let quiet = 4
    let scale = max(1, 1200 / (modules + quiet * 2))
    let side = (modules + quiet * 2) * scale

    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = context
    context.imageInterpolation = .none   // 拡大してもぼかさない(モジュールの縁をくっきり)
    NSColor.white.setFill()
    NSRect(x: 0, y: 0, width: side, height: side).fill()
    let cg = CIContext().createCGImage(qr, from: qr.extent)!
    let offset = quiet * scale
    context.cgContext.interpolationQuality = .none
    context.cgContext.draw(cg, in: CGRect(x: offset, y: offset, width: modules * scale, height: modules * scale))
    NSGraphicsContext.restoreGraphicsState()

    let file = outputFolder.appendingPathComponent("\(route).png")
    try! rep.representation(using: .png, properties: [:])!.write(to: file)
    print("\(route).png  \(side)x\(side)px  → \(url)")
}
