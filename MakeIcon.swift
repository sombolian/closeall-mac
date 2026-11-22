// Draws the CloseAll app icon (red rounded square with a white X) as a 1024px PNG.
import AppKit

let px = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let s = CGFloat(px)
// macOS icon grid: ~824px body centred in a 1024px canvas
let body = NSRect(x: 100, y: 100, width: s - 200, height: s - 200)
let shape = NSBezierPath(roundedRect: body, xRadius: 186, yRadius: 186)

// Soft drop shadow
NSGraphicsContext.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
shadow.shadowBlurRadius = 24
shadow.shadowOffset = NSSize(width: 0, height: -12)
shadow.set()
NSColor(srgbRed: 0.85, green: 0.12, blue: 0.14, alpha: 1).setFill()
shape.fill()
NSGraphicsContext.restoreGraphicsState()

// Red gradient, lighter at the top
NSGradient(starting: NSColor(srgbRed: 1.00, green: 0.42, blue: 0.38, alpha: 1),
           ending: NSColor(srgbRed: 0.82, green: 0.08, blue: 0.12, alpha: 1))!
    .draw(in: shape, angle: -90)

// Subtle top highlight
NSGraphicsContext.saveGraphicsState()
shape.addClip()
NSGradient(starting: NSColor.white.withAlphaComponent(0.18), ending: NSColor.white.withAlphaComponent(0))!
    .draw(in: NSRect(x: body.minX, y: body.midY, width: body.width, height: body.height / 2), angle: -90)
NSGraphicsContext.restoreGraphicsState()

// White X with a slight shadow
NSGraphicsContext.saveGraphicsState()
let xs = NSShadow()
xs.shadowColor = NSColor.black.withAlphaComponent(0.18)
xs.shadowBlurRadius = 10
xs.shadowOffset = NSSize(width: 0, height: -6)
xs.set()
let c = s / 2, d: CGFloat = 175
let x = NSBezierPath()
x.lineWidth = 112
x.lineCapStyle = .round
x.move(to: NSPoint(x: c - d, y: c - d)); x.line(to: NSPoint(x: c + d, y: c + d))
x.move(to: NSPoint(x: c - d, y: c + d)); x.line(to: NSPoint(x: c + d, y: c - d))
NSColor.white.setStroke()
x.stroke()
NSGraphicsContext.restoreGraphicsState()

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!
    .write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
