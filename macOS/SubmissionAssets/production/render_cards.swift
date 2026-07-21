import AppKit
import Foundation

guard CommandLine.arguments.count == 6 else {
    fputs("Usage: render_cards.swift <icon> <dashboard> <intro.png> <outro.png> <thumbnail.png>\n", stderr)
    exit(2)
}

let iconPath = CommandLine.arguments[1]
let dashboardPath = CommandLine.arguments[2]
let introPath = CommandLine.arguments[3]
let outroPath = CommandLine.arguments[4]
let thumbnailPath = CommandLine.arguments[5]

guard let icon = NSImage(contentsOfFile: iconPath),
      let dashboard = NSImage(contentsOfFile: dashboardPath) else {
    fputs("Unable to load icon or dashboard source image.\n", stderr)
    exit(3)
}

let deepIndigo = NSColor(calibratedRed: 0.035, green: 0.043, blue: 0.090, alpha: 1)
let softIndigo = NSColor(calibratedRed: 0.43, green: 0.47, blue: 1.0, alpha: 1)
let warmOrange = NSColor(calibratedRed: 1.0, green: 0.62, blue: 0.08, alpha: 1)
let mutedText = NSColor(calibratedWhite: 0.72, alpha: 1)

func drawText(
    _ text: String,
    in rect: NSRect,
    size: CGFloat,
    weight: NSFont.Weight,
    color: NSColor,
    alignment: NSTextAlignment = .center,
    rounded: Bool = false
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping
    let font = rounded
        ? NSFont.systemFont(ofSize: size, weight: weight)
        : NSFont.systemFont(ofSize: size, weight: weight)
    (text as NSString).draw(in: rect, withAttributes: [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: size > 30 ? -0.5 : 0
    ])
}

func render(size: NSSize, drawing: @escaping (NSRect) -> Void) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    drawing(NSRect(origin: .zero, size: size))
    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String) throws {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw NSError(domain: "SimpleBoardVideo", code: 1)
    }
    let representation = NSBitmapImageRep(cgImage: cgImage)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "SimpleBoardVideo", code: 2)
    }
    try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}

func drawBackground(in rect: NSRect) {
    NSGradient(colors: [deepIndigo, NSColor(calibratedRed: 0.075, green: 0.055, blue: 0.18, alpha: 1)])!
        .draw(in: rect, angle: -22)
    softIndigo.withAlphaComponent(0.16).setFill()
    NSBezierPath(ovalIn: NSRect(x: rect.width * 0.64, y: rect.height * 0.52, width: 650, height: 650)).fill()
}

func drawRoundedIcon(_ image: NSImage, in rect: NSRect) {
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(
        roundedRect: rect,
        xRadius: rect.width * 0.22,
        yRadius: rect.height * 0.22
    ).addClip()
    image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()
}

let intro = render(size: NSSize(width: 1920, height: 1080)) { rect in
    drawBackground(in: rect)
    drawRoundedIcon(icon, in: NSRect(x: 845, y: 665, width: 230, height: 230))
    drawText("SIMPLE BOARD", in: NSRect(x: 250, y: 505, width: 1420, height: 110), size: 78, weight: .bold, color: .white, rounded: true)
    drawText("Every first day should feel ready.", in: NSRect(x: 260, y: 405, width: 1400, height: 70), size: 42, weight: .medium, color: NSColor(calibratedRed: 0.78, green: 0.80, blue: 1.0, alpha: 1))
    warmOrange.setFill()
    NSBezierPath(roundedRect: NSRect(x: 850, y: 340, width: 220, height: 7), xRadius: 4, yRadius: 4).fill()
}

let outro = render(size: NSSize(width: 1920, height: 1080)) { rect in
    drawBackground(in: rect)
    drawRoundedIcon(icon, in: NSRect(x: 865, y: 745, width: 190, height: 190))
    drawText("Clear for leaders. Actionable for employees.", in: NSRect(x: 180, y: 545, width: 1560, height: 100), size: 56, weight: .bold, color: .white, rounded: true)
    drawText("github.com/abadikaka/simpleboard", in: NSRect(x: 260, y: 450, width: 1400, height: 58), size: 34, weight: .medium, color: NSColor(calibratedRed: 0.68, green: 0.71, blue: 1.0, alpha: 1))
    drawText("Synthetic narration generated locally with macOS", in: NSRect(x: 260, y: 110, width: 1400, height: 42), size: 24, weight: .regular, color: mutedText)
}

let thumbnail = render(size: NSSize(width: 1280, height: 720)) { rect in
    dashboard.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    NSColor(calibratedWhite: 0.015, alpha: 0.68).setFill()
    rect.fill()
    NSGradient(colors: [deepIndigo.withAlphaComponent(0.95), deepIndigo.withAlphaComponent(0.15)])!
        .draw(in: rect, angle: 0)
    drawRoundedIcon(icon, in: NSRect(x: 78, y: 500, width: 145, height: 145))
    drawText("ONBOARDING THAT", in: NSRect(x: 80, y: 382, width: 920, height: 55), size: 42, weight: .semibold, color: NSColor(calibratedRed: 0.68, green: 0.71, blue: 1.0, alpha: 1), alignment: .left)
    drawText("CLOSES THE LOOP", in: NSRect(x: 75, y: 282, width: 1120, height: 100), size: 78, weight: .heavy, color: .white, alignment: .left, rounded: true)
    drawText("OWNER  →  EMPLOYEE  →  OUTCOME", in: NSRect(x: 82, y: 205, width: 1020, height: 48), size: 32, weight: .bold, color: warmOrange, alignment: .left)
    drawText("Built with Codex + GPT-5.6", in: NSRect(x: 82, y: 72, width: 720, height: 44), size: 28, weight: .medium, color: .white, alignment: .left)
}

try savePNG(intro, to: introPath)
try savePNG(outro, to: outroPath)
try savePNG(thumbnail, to: thumbnailPath)

print("Rendered intro, outro, and thumbnail.")
