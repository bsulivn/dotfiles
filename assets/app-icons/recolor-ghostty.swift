import CoreGraphics
import Foundation
import ImageIO

// Recolor the stock Ghostty icon without changing its silhouette or artwork.
guard CommandLine.arguments.count == 3 else {
  fputs("usage: recolor-ghostty.swift INPUT.png OUTPUT.png\n", stderr)
  exit(2)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2]) as CFURL
guard let source = CGImageSourceCreateWithURL(inputURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
  fputs("could not read input image\n", stderr)
  exit(1)
}

let width = image.width
let height = image.height
let bytesPerRow = width * 4
let colorSpace = CGColorSpaceCreateDeviceRGB()
var input = [UInt8](repeating: 0, count: width * height * 4)
var output = [UInt8](repeating: 0, count: input.count)
let context = CGContext(data: &input, width: width, height: height, bitsPerComponent: 8,
                        bytesPerRow: bytesPerRow, space: colorSpace,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

struct RGB { let r: Double; let g: Double; let b: Double }
let shadow = RGB(r: 31, g: 39, b: 41)       // Everforest bg_dim
let surface = RGB(r: 45, g: 53, b: 59)      // Everforest bg0
let frame = RGB(r: 86, g: 99, b: 91)        // Everforest bg3 / green-grey
let cream = RGB(r: 211, g: 198, b: 170)     // Everforest fg
let aqua = RGB(r: 131, g: 192, b: 146)      // Everforest aqua/green
let green = RGB(r: 167, g: 192, b: 128)     // Everforest green

func mix(_ a: RGB, _ b: RGB, _ amount: Double) -> RGB {
  let t = max(0, min(1, amount))
  return RGB(r: a.r + (b.r - a.r) * t, g: a.g + (b.g - a.g) * t, b: a.b + (b.b - a.b) * t)
}

for pixel in 0..<(width * height) {
  let i = pixel * 4
  let alpha = Double(input[i + 3]) / 255
  if alpha == 0 { continue }
  let unpremultiply = 1 / alpha
  let color = RGB(r: Double(input[i]) * unpremultiply,
                  g: Double(input[i + 1]) * unpremultiply,
                  b: Double(input[i + 2]) * unpremultiply)
  let brightness = (color.r + color.g + color.b) / (255 * 3)
  let blueSignal = color.b - max(color.r, color.g)
  let mapped: RGB

  if blueSignal > 10 {
    // Preserve the original screen's shading, but move its blue values through
    // Everforest's dark surface → aqua → green range.
    if brightness < 0.24 {
      mapped = mix(shadow, surface, brightness / 0.24)
    } else if brightness < 0.58 {
      mapped = mix(surface, aqua, (brightness - 0.24) / 0.34)
    } else {
      mapped = mix(aqua, green, (brightness - 0.58) / 0.42)
    }
  } else if brightness < 0.18 {
    mapped = mix(shadow, surface, brightness / 0.18)
  } else if brightness < 0.62 {
    mapped = mix(surface, frame, (brightness - 0.18) / 0.44)
  } else {
    // The Ghostty mark and metal highlights become warm Everforest cream.
    mapped = mix(frame, cream, (brightness - 0.62) / 0.38)
  }

  output[i] = UInt8(max(0, min(255, mapped.r * alpha)).rounded())
  output[i + 1] = UInt8(max(0, min(255, mapped.g * alpha)).rounded())
  output[i + 2] = UInt8(max(0, min(255, mapped.b * alpha)).rounded())
  output[i + 3] = input[i + 3]
}

guard let outputContext = CGContext(data: &output, width: width, height: height,
                                    bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
      let outputImage = outputContext.makeImage(),
      let destination = CGImageDestinationCreateWithURL(outputURL, "public.png" as CFString, 1, nil) else {
  fputs("could not create output image\n", stderr)
  exit(1)
}
CGImageDestinationAddImage(destination, outputImage, nil)
if !CGImageDestinationFinalize(destination) {
  fputs("could not write output image\n", stderr)
  exit(1)
}
