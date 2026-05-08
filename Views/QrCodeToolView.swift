//
//  QrCodeToolView.swift
//  Arithmetic
//
import SwiftUI
import AVFoundation
import CoreImage
import UIKit
import CoreImage.CIFilter
import UniformTypeIdentifiers
import Arithmetic

struct QrCodeToolView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var scanResult = ""
    @State private var textInput = ""
    @State private var qrCodeImage: Image?
    @State private var generatedQRCodeUIImage: UIImage?
    @State private var scannedQRCodeImage: Image?
    @State private var alertItem: AlertItem?
    @State private var shouldShowCamera = false
    @State private var shouldShowImageFilePicker = false
    @State private var isScanResultCopied = false
    @State private var shouldShowQRCodeShareSheet = false
    @State private var qrCodeExportURL: URL?

    // Calculate adaptive QR code size
    var qrCodeSize: CGFloat {
        horizontalSizeClass == .regular ? 300 : 240
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.10), Color.teal.opacity(0.08), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        VStack(spacing: 10) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(.blue)

                            Text("qr_code.tool.title".localized)
                                .font(.adaptiveTitle())
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)

                            Text("qr_code.tool.description".localized)
                                .font(.adaptiveBody())
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(cardBackground)

                        VStack(spacing: 12) {
                            actionButton(
                                icon: "camera.fill",
                                title: "qr_code.scan_camera_button".localized,
                                tint: .blue
                            ) {
                                checkCameraPermission()
                            }

                            actionButton(
                                icon: "folder.fill",
                                title: "qr_code.scan_photos_button".localized,
                                tint: .teal
                            ) {
                                shouldShowImageFilePicker = true
                            }
                        }
                        .padding(16)
                        .background(cardBackground)

                        if !scanResult.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionHeader(
                                    title: "qr_code.scan_result".localized,
                                    icon: "checkmark.seal.fill",
                                    color: .green
                                )

                                CopyableInfoRow(
                                    label: "qr_code.scan_result".localized,
                                    value: scanResult,
                                    isCopied: $isScanResultCopied
                                )

                                if let scannedImage = scannedQRCodeImage {
                                    VStack(spacing: 8) {
                                        Text("qr_code.scanned_image_label".localized)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        scannedImage
                                            .resizable()
                                            .frame(width: qrCodeSize - 40, height: qrCodeSize - 40)
                                            .scaledToFit()
                                            .cornerRadius(14)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(16)
                            .background(cardBackground)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(
                                title: "qr_code.text_input_label".localized,
                                icon: "text.alignleft",
                                color: .indigo
                            )

                            ZStack(alignment: .topLeading) {
                                if textInput.isEmpty {
                                    Text("qr_code.placeholder_text".localized)
                                        .foregroundStyle(.gray)
                                        .padding(14)
                                }

                                TextEditor(text: $textInput)
                                    .frame(height: 110)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                    )
                                    .font(.body)
                            }

                            Button(action: {
                                generateQRCode(from: textInput)
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("qr_code.generate_button".localized)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .foregroundStyle(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(textInput.isEmpty ? Color.gray.opacity(0.4) : Color.green)
                                )
                            }
                            .disabled(textInput.isEmpty)
                        }
                        .padding(16)
                        .background(cardBackground)

                        if let qrCodeImage = qrCodeImage {
                            VStack(spacing: 12) {
                                sectionHeader(
                                    title: "qr_code.generated_qr".localized,
                                    icon: "checkmark.seal.fill",
                                    color: .green
                                )

                                qrCodeImage
                                    .resizable()
                                    .frame(width: qrCodeSize, height: qrCodeSize)
                                    .scaledToFit()
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                                    .onLongPressGesture {
                                        prepareQRCodeForSharing()
                                    }

                                Text("qr_code.long_press_save_hint".localized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .background(cardBackground)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 36)
                }
            }
        }
        .navigationTitle("qr_code.tool.title".localized)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("button.back".localized)
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
        .alert(item: $alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title.localized),
                message: Text(alertItem.message.localized),
                dismissButton: .default(Text("button.ok".localized))
            )
        }
        .fileImporter(
            isPresented: $shouldShowImageFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let imageURL = urls.first else { return }
                do {
                    let imageData = try Data(contentsOf: imageURL)
                    if let uiImage = UIImage(data: imageData) {
                        processQRCode(from: uiImage)
                    } else {
                        alertItem = AlertItem(
                            title: "qr_code.error_title".localized,
                            message: "qr_code.no_qr_code_found".localized
                        )
                    }
                } catch {
                    alertItem = AlertItem(
                        title: "qr_code.error_title".localized,
                        message: "qr_code.no_qr_code_found".localized
                    )
                }
            case .failure:
                break
            }
        }
        .sheet(isPresented: $shouldShowQRCodeShareSheet) {
            if let qrCodeExportURL {
                ShareSheet(items: [qrCodeExportURL])
            }
        }
        .sheet(isPresented: $shouldShowCamera) {
            QrCodeScannerView(
                scanResult: $scanResult,
                scannedQRCodeImage: $scannedQRCodeImage
            )
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(.systemBackground).opacity(0.88))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private func actionButton(icon: String, title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 26)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tint.opacity(0.13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(tint.opacity(0.25), lineWidth: 1)
                    )
            )
            .foregroundStyle(tint)
        }
    }

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 14, weight: .semibold))
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    private func processQRCode(from uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else { return }

        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage)

        if let feature = features?.first as? CIQRCodeFeature, let message = feature.messageString {
            scanResult = message
            scannedQRCodeImage = Image(uiImage: uiImage)
        } else {
            alertItem = AlertItem(
                title: "qr_code.error_title".localized,
                message: "qr_code.no_qr_code_found".localized
            )
        }
    }

    private func generateQRCode(from string: String) {
        guard !string.isEmpty else {
            // Clear the QR code if the input is empty
            qrCodeImage = nil
            generatedQRCodeUIImage = nil
            return
        }

        let context = CIContext()
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            showQRCodeGenerationError()
            return
        }

        // Configure the QR code generator
        configureQRCodeFilter(filter, with: string)

        // Generate the CIImage from the filter
        guard let outputImage = filter.outputImage else {
            showQRCodeGenerationError()
            return
        }

        // Scale the QR code to improve resolution
        let scaledImage = scaleQRCode(outputImage)

        // Convert the CIImage to a CGImage and then to a an Image
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            generatedQRCodeUIImage = uiImage
            qrCodeImage = Image(uiImage: uiImage)
        } else {
            showQRCodeGenerationError()
        }
    }

    /// Configures the CIQRCodeGenerator filter with the input string and error correction level.
    private func configureQRCodeFilter(_ filter: CIFilter, with string: String) {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
    }

    /// Scales the QR code image to a larger size for better resolution.
    private func scaleQRCode(_ image: CIImage) -> CIImage {
        let scaleFactor: CGFloat = 12.0 // Upsampling for clarity
        let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        return image.transformed(by: transform)
    }

    /// Displays an alert for a QR code generation error.
    private func showQRCodeGenerationError() {
        alertItem = AlertItem(
            title: "qr_code.error_title".localized,
            message: "qr_code.generation_error".localized
        )
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            shouldShowCamera = true
        case .notDetermined:
            // Request permission
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run {
                    if granted {
                        shouldShowCamera = true
                    } else {
                        alertItem = AlertItem(
                            title: "qr_code.permission_error_title".localized,
                            message: "qr_code.permission_error_message".localized
                        )
                    }
                }
            }
        case .denied, .restricted:
            alertItem = AlertItem(
                title: "qr_code.permission_error_title".localized,
                message: "qr_code.permission_error_message".localized
            )
        @unknown default:
            alertItem = AlertItem(
                title: "qr_code.error_title".localized,
                message: "qr_code.permission_error_message".localized
            )
        }
    }

    private func prepareQRCodeForSharing() {
        guard let imageData = generatedQRCodeUIImage?.pngData() else {
            alertItem = AlertItem(
                title: "qr_code.error_title".localized,
                message: "qr_code.export_error".localized
            )
            return
        }

        let fileName = "qrcode-\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            try imageData.write(to: fileURL)
            qrCodeExportURL = fileURL
            shouldShowQRCodeShareSheet = true
        } catch {
            alertItem = AlertItem(
                title: "qr_code.error_title".localized,
                message: "qr_code.export_error".localized
            )
        }
    }
}

// MARK: - Copyable Info Row Component
private struct CopyableInfoRow: View {
    let label: String
    let value: String
    @Binding var isCopied: Bool
    @State private var showToast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)

                Spacer()

                Button(action: copyToClipboard) {
                    HStack(spacing: 6) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12, weight: .semibold))
                        Text(isCopied ? "copied_status".localized : "copy_button".localized)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isCopied ? Color.green : Color.blue)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }

            Text(value)
                .font(.system(.body, design: .monospaced))
                .lineLimit(2)
                .truncationMode(.middle)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(.adaptiveCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(.adaptiveCornerRadius * 1.5)
        .overlay(
            RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = value
        isCopied = true

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isCopied = false
        }
    }
}

struct QrCodeToolView_Previews: PreviewProvider {
    static var previews: some View {
        QrCodeToolView()
            .environmentObject(LocalizationManager())
    }
}

// Supporting structures
private struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// QR Code Scanner View
struct QrCodeScannerView: UIViewControllerRepresentable {
    @Binding var scanResult: String
    @Binding var scannedQRCodeImage: Image?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        return QRCodeScannerViewController(
            scanResult: $scanResult,
            scannedQRCodeImage: $scannedQRCodeImage,
            presentationMode: presentationMode
        )
    }

    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {}
}

// QR Code Scanner View Controller
class QRCodeScannerViewController: UIViewController {
    private let captureSession = AVCaptureSession()
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    private let qrCodeFrameView = UIView()
    private var scanResult: Binding<String>
    private var scannedQRCodeImage: Binding<Image?>
    private var presentationMode: Binding<PresentationMode>

    init(
        scanResult: Binding<String>,
        scannedQRCodeImage: Binding<Image?>,
        presentationMode: Binding<PresentationMode>
    ) {
        self.scanResult = scanResult
        self.scannedQRCodeImage = scannedQRCodeImage
        self.presentationMode = presentationMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        captureSession.stopRunning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera device available")
            DispatchQueue.main.async {
                self.showPermissionDeniedAlert()
            }
            return
        }

        // Set up the session directly since permission is handled in SwiftUI view
        setupSession(captureDevice: captureDevice)
    }

    private func setupSession(captureDevice: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Configure capture session on background queue to prevent blocking
            captureSession.beginConfiguration()

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Cannot add camera input to capture session")
                captureSession.commitConfiguration()
                showPermissionDeniedAlert()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                print("Cannot add metadata output to capture session")
                captureSession.commitConfiguration()
                showPermissionDeniedAlert()
                return
            }

            captureSession.commitConfiguration()
        } catch {
            print("Error setting up capture session: \(error)")
            DispatchQueue.main.async {
                self.showPermissionDeniedAlert()
            }
            return
        }

        DispatchQueue.main.async {
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspectFill
            self.videoPreviewLayer.frame = self.view.layer.bounds
            self.view.layer.addSublayer(self.videoPreviewLayer)

            self.qrCodeFrameView.layer.borderColor = UIColor.systemGreen.cgColor
            self.qrCodeFrameView.layer.borderWidth = 3
            self.view.addSubview(self.qrCodeFrameView)

            // Add cancel button
            let cancelButton = UIButton(type: .system)
            cancelButton.setTitle("alert.cancel".localized, for: .normal)
            cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            cancelButton.setTitleColor(.white, for: .normal)
            cancelButton.layer.cornerRadius = 12
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped), for: .touchUpInside)
            self.view.addSubview(cancelButton)

            // Setup constraints for cancel button
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cancelButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
                cancelButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                cancelButton.heightAnchor.constraint(equalToConstant: 44),
                cancelButton.widthAnchor.constraint(equalToConstant: 120)
            ])
        }

        // Start capture session on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer.frame = view.bounds
    }

    @objc private func cancelButtonTapped() {
        presentationMode.wrappedValue.dismiss()
    }

    private func showPermissionDeniedAlert() {
        DispatchQueue.main.async {
            let alertTitle = "qr_code.permission_error_title".localized
            let alertMessage = "qr_code.permission_error_message".localized
            let settingsTitle = "qr_code.open_settings".localized

            let alert = UIAlertController(
                title: alertTitle,
                message: alertMessage,
                preferredStyle: .alert
            )

            // Add settings action if permission was denied
            if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
                alert.addAction(UIAlertAction(
                    title: settingsTitle,
                    style: .default
                ) { _ in
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
            }

            alert.addAction(UIAlertAction(
                title: "button.ok".localized,
                style: .default
            ) { _ in
                self.presentationMode.wrappedValue.dismiss()
            })
            self.present(alert, animated: true)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                AudioServicesPlaySystemSound(SystemSoundID(1005))
                self.scanResult.wrappedValue = stringValue

                // Capture the QR code image
                if let capturedImage = self.captureQRCodeImage() {
                    self.scannedQRCodeImage.wrappedValue = Image(uiImage: capturedImage)
                }

                // Stop capture session after successful scan
                self.captureSession.stopRunning()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func captureQRCodeImage() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.layer.frame.size, false, scale)

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
