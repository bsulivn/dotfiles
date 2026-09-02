import CoreGraphics
import Foundation
import ImageIO

guard CommandLine.arguments.count == 3 else {
  fputs("usage: recolor-vscode.swift INPUT.png OUTPUT.png\n", stderr); exit(2)
}
let inputURL = URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2]) as CFURL
guard let source = CGImageSourceCreateWithURL(inputURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
  fputs("could not read input image\n", stderr); exit(1)
}
let width = image.width, height = image.height, rowBytes = width * 4
let space = CGColorSpaceCreateDeviceRGB()
var input = [UInt8](repeating: 0, count: width * height * 4)
var output = [UInt8](repeating: 0, count: input.count)
let context = CGContext(data: &input, width: width, height: height, bitsPerComponent: 8,
                        bytesPerRow: rowBytes, space: space,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

struct RGB { let r: Double; let g: Double; let b: Double }
let stock = [RGB(r: 31, g: 156, b: 240), RGB(r: 0, g: 122, b: 204), RGB(r: 0, g: 101, b: 169)]
let forest = [RGB(r: 167, g: 192, b: 128), RGB(r: 131, g: 192, b: 146), RGB(r: 127, g: 187, b: 179)]
let background = RGB(r: 45, g: 53, b: 59)
let shadow = RGB(r: 35, g: 42, b: 46)
func distance(_ a: RGB, _ b: RGB) -> Double {
  let r = a.r - b.r, g = a.g - b.g, b = a.b - b.b
  return r * r + g * g + b * b
}
func mix(_ a: RGB, _ b: RGB, _ t: Double) -> RGB {
  let t = max(0, min(1, t))
  return RGB(r: a.r + (b.r - a.r) * t, g: a.g + (b.g - a.g) * t, b: a.b + (b.b - a.b) * t)
}

for pixel in 0..<(width * height) {
  let i = pixel * 4
  let alpha = Double(input[i + 3]) / 255
  if alpha == 0 { continue }
  let factor = 1 / alpha
  let color = RGB(r: Double(input[i]) * factor, g: Double(input[i + 1]) * factor, b: Double(input[i + 2]) * factor)
  var best = 0, opacity = 0.0, error = Double.greatestFiniteMagnitude
  for (index, blue) in stock.enumerated() {
    let d = RGB(r: blue.r - 255, g: blue.g - 255, b: blue.b - 255)
    let p = RGB(r: color.r - 255, g: color.g - 255, b: color.b - 255)
    let denominator = d.r * d.r + d.g * d.g + d.b * d.b
    let blend = max(0, min(1, (p.r * d.r + p.g * d.g + p.b * d.b) / denominator))
    let predicted = RGB(r: 255 + d.r * blend, g: 255 + d.g * blend, b: 255 + d.b * blend)
    let candidateError = distance(color, predicted)
    if candidateError < error { best = index; opacity = blend; error = candidateError }
  }
  let brightness = (color.r + color.g + color.b) / (255 * 3)
  let mapped: RGB
  if opacity > 0.08 && color.b > color.r + 18 {
    mapped = mix(background, forest[best], opacity)
  } else {
    mapped = mix(shadow, background, pow(max(0, min(1, brightness)), 1.35))
  }
  output[i] = UInt8(max(0, min(255, mapped.r * alpha)).rounded())
  output[i + 1] = UInt8(max(0, min(255, mapped.g * alpha)).rounded())
  output[i + 2] = UInt8(max(0, min(255, mapped.b * alpha)).rounded())
  output[i + 3] = input[i + 3]
}

guard let outputContext = CGContext(data: &output, width: width, height: height, bitsPerComponent: 8,
                                    bytesPerRow: rowBytes, space: space,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
      let outputImage = outputContext.makeImage(),
      let destination = CGImageDestinationCreateWithURL(outputURL, "public.png" as CFString, 1, nil) else {
  fputs("could not create output image\n", stderr); exit(1)
}
CGImageDestinationAddImage(destination, outputImage, nil)
if !CGImageDestinationFinalize(destination) { fputs("could not write output image\n", stderr); exit(1) }
