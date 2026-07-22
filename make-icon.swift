// Generates CostBar's app icon as a 1024x1024 PNG.
// A dark-green rounded tile with an ascending bar chart; the tallest bar
// carries a dollar mark. Run: swift make-icon.swift && (converted to .icns by build).
import AppKit

let S: CGFloat = 1024
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
guard let ctx = NSGraphicsContext.current?.cgContext else { fatalError("no ctx") }

// Background: rounded squircle, dark-green vertical gradient (BC palette).
let inset: CGFloat = 0
let rect = CGRect(x: inset, y: inset, width: S - inset*2, height: S - inset*2)
let corner: CGFloat = S * 0.225   // macOS Big Sur-ish radius
let path = CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
ctx.addPath(path); ctx.clip()

let cs = CGColorSpaceCreateDeviceRGB()
let top    = CGColor(colorSpace: cs, components: [0.043, 0.196, 0.149, 1])!  // #0B3226
let bottom = CGColor(colorSpace: cs, components: [0.020, 0.118, 0.090, 1])!  // #051E17
let grad = CGGradient(colorsSpace: cs, colors: [top, bottom] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: S), end: CGPoint(x: 0, y: 0), options: [])

// Bars: three ascending columns, mint green.
let mint = CGColor(colorSpace: cs, components: [0.286, 0.882, 0.604, 1])!     // #49E19A
let mintDim = CGColor(colorSpace: cs, components: [0.286, 0.882, 0.604, 0.55])!
let baseY: CGFloat = S * 0.27
let barW: CGFloat = S * 0.135
let gap: CGFloat = S * 0.075
let totalW = barW*3 + gap*2
let startX = (S - totalW) / 2
let heights: [CGFloat] = [S*0.20, S*0.32, S*0.46]
let colors  = [mintDim, mintDim, mint]
let barCorner: CGFloat = barW * 0.32

for i in 0..<3 {
    let x = startX + CGFloat(i)*(barW+gap)
    let r = CGRect(x: x, y: baseY, width: barW, height: heights[i])
    let bp = CGPath(roundedRect: r, cornerWidth: barCorner, cornerHeight: barCorner, transform: nil)
    ctx.addPath(bp); ctx.setFillColor(colors[i]); ctx.fillPath()
}

// Dollar mark centered on the tallest (right) bar.
let tallX = startX + 2*(barW+gap)
let dollarRect = CGRect(x: tallX - barW*0.6, y: baseY + heights[2] - barW*2.05,
                        width: barW*2.2, height: barW*2.2)
let para = NSMutableParagraphStyle(); para.alignment = .center
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: S*0.18, weight: .heavy),
    .foregroundColor: NSColor(red: 0.020, green: 0.118, blue: 0.090, alpha: 1),
    .paragraphStyle: para,
]
NSString(string: "$").draw(in: dollarRect, withAttributes: attrs)

img.unlockFocus()

guard let tiff = img.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { fatalError("encode failed") }
let out = URL(fileURLWithPath: "icon-1024.png")
try! png.write(to: out)
print("wrote \(out.path)")
