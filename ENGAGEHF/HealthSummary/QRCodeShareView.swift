//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CoreImage.CIFilterBuiltins
import SwiftUI


struct QRCodeShareView: View {
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness
    @State private var qrCodeImage: UIImage?
    
    let url: String
    let code: String
    let timeRemaining: Int
    
    
    var body: some View {
        VStack {
            GroupBox(label: Text("Health Summary QR Code")) {
                VStack(alignment: .leading) {
                    Text("This QR code can be scanned by your healthcare provider to share your health summary.")
                    VStack {
                        Text("Expires in: \(Int(timeRemaining) / 60):\(String(format: "%02d", Int(timeRemaining) % 60))")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        if let image = qrCodeImage {
                            Image(uiImage: image)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .accessibilityLabel("QR code for sharing your health summary with your doctor")
                        }
                    }
                        .padding(.top)
                    GroupBox {
                        HStack {
                            Text("One-time Code")
                                .bold()
                            Spacer()
                            Text(code.uppercased())
                                .font(.body.monospaced())
                        }
                    }
                }
            }
                .padding()
            Spacer()
        }
            .task(id: url) {
                qrCodeImage = generateQRCode(from: url)
            }
            .onAppear {
                UIScreen.main.brightness = 1.0
            }
            .onDisappear {
                UIScreen.main.brightness = originalBrightness
            }
    }
       
    
    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    QRCodeShareView(url: "/example-link", code: "1111", timeRemaining: 10)
}
