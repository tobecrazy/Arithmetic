//
//  QrCodeToolView.swift
//  Arithmetic
//
import SwiftUI
import AVFoundation
import CoreImage
import UIKit
import CoreImage.CIFilter

struct QrCodeToolView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var scanResult = ""
    @State private var textInput = ""
    @State private var qrCodeImage: Image?
    @State private var scannedQRCodeImage: Image?
    @State private var alertItem: AlertItem?
    @State private var shouldShowCamera = false

    // Calculate adaptive QR code size
    var qrCodeSize: CGFloat {
        horizontalSizeClass == .regular ? 300 : 240
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(spacing: 15) {
                        Text("qr_code.tool.title".localized)
                            .font(.adaptiveTitle())
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text("qr_code.tool.description".localized)
                            .font(.adaptiveBody())
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Scan QR Code Button
                    Button(action: {
                        checkCameraPermission()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "viewfinder")
                                .font(.system(size: 18, weight: .semibold))
                            Text("qr_code.scan_button".localized)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .opacity(0.6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 20)
                    .sheet(isPresented: $shouldShowCamera) {
                        QrCodeScannerView(
                            scanResult: $scanResult,
                            scannedQRCodeImage: $scannedQRCodeImage
                        )
                    }
                    
                    // Scan Result Display
                    if !scanResult.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text("qr_code.scan_result".localized)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }

                            Text(scanResult)
                                .font(.body)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                                )
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)

                        if let scannedImage = scannedQRCodeImage {
                            VStack(spacing: 8) {
                                Text("qr_code.scanned_image_label".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                scannedImage
                                    .resizable()
                                    .frame(width: qrCodeSize - 40, height: qrCodeSize - 40)
                                    .scaledToFit()
                                    .cornerRadius(10)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 20)
                        }
                    }

                    // Text Input for QR Generation
                    VStack(alignment: .leading, spacing: 10) {
                        Text("qr_code.text_input_label".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        ZStack(alignment: .topLeading) {
                            if textInput.isEmpty {
                                Text("qr_code.placeholder_text".localized)
                                    .foregroundColor(.gray)
                                    .padding(12)
                            }

                            TextEditor(text: $textInput)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                                )
                                .font(.body)
                        }
                        .padding(.horizontal, 20)
                    }

                    // Generate QR Code Button
                    Button(action: {
                        generateQRCode(from: textInput)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 18, weight: .semibold))
                            Text("qr_code.generate_button".localized)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .opacity(0.6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(textInput.isEmpty ? Color.gray.opacity(0.1) : Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(textInput.isEmpty ? Color.gray.opacity(0.2) : Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .foregroundColor(textInput.isEmpty ? .gray : .green)
                    }
                    .padding(.horizontal, 20)
                    .disabled(textInput.isEmpty)

                    // Generated QR Code Display
                    if let qrCodeImage = qrCodeImage {
                        VStack(alignment: .center, spacing: 12) {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text("qr_code.generated_qr".localized)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }

                            qrCodeImage
                                .resizable()
                                .frame(width: qrCodeSize, height: qrCodeSize)
                                .scaledToFit()
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
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
                    .foregroundColor(.blue)
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
    }

    private func generateQRCode(from string: String) {
        let context = CIContext()
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            alertItem = AlertItem(
                title: "qr_code.error_title".localized,
                message: "qr_code.generation_error".localized
            )
            return
        }

        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        // Set error correction level to maximum for better reliability
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard var outputImage = filter.outputImage else {
            alertItem = AlertItem(
                title: "qr_code.error_title".localized,
                message: "qr_code.generation_error".localized
            )
            return
        }

        // Scale up the QR code for better resolution (10x upsampling)
        let scaleFactor: CGFloat = 10.0
        let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        outputImage = outputImage.transformed(by: scaleTransform)

        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            qrCodeImage = Image(uiImage: UIImage(cgImage: cgImage))
        } else {
            alertItem = AlertItem(
                title: "qr_code.error_title".localized,
                message: "qr_code.generation_error".localized
            )
        }
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
}

struct QrCodeToolView_Previews: PreviewProvider {
    static var previews: some View {
        QrCodeToolView()
            .environmentObject(LocalizationManager())
    }
}

// Supporting structures
struct AlertItem: Identifiable {
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

            // Add close button with improved styling
            let closeButton = UIButton(type: .system)
            closeButton.setTitle("qr_code.close_camera".localized, for: .normal)
            closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            closeButton.setTitleColor(.white, for: .normal)
            closeButton.layer.cornerRadius = 12
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            closeButton.addTarget(self, action: #selector(self.closeButtonTapped), for: .touchUpInside)
            self.view.addSubview(closeButton)

            // Setup constraints with improved positioning
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
                closeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                closeButton.heightAnchor.constraint(equalToConstant: 44),
                closeButton.widthAnchor.constraint(equalToConstant: 100)
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

    @objc private func closeButtonTapped() {
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