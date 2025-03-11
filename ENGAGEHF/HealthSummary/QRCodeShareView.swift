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
    let url: String
    let code: String
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    
    var body: some View {
        VStack {
            GroupBox(label: Text("Health Summary QR Code")) {
                Text("This QR code can be scanned by your doctor to share your health summary.")
                    .padding(.top)
                Image(uiImage: generateQRCode(from: url))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .accessibilityLabel("QR code for sharing your health summary with your doctor")
                GroupBox {
                    HStack {
                        Text("One-time Code")
                        Spacer()
                        Text(code.uppercased())
                    }
                }
            }
                .padding()
            Spacer()
        }
    }
    
    
    private func generateQRCode(from string: String) -> UIImage {
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
    QRCodeShareView(url: "/example-link", code: "1111")
}
