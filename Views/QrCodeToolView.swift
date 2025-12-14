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
    @State private var isScanning = false
    @State private var scanResult = ""
    @State private var textInput = ""
    @State private var qrCodeImage: Image?
    @State private var scannedQRCodeImage: Image?
    @State private var alertItem: AlertItem?
    @State private var cameraPermissionGranted = false
    @State private var shouldShowCamera = false
    
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
                        HStack {
                            Image(systemName: "viewfinder")
                                .foregroundColor(.blue)
                            Text("qr_code.scan_button".localized)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("qr_code.scan_result".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(scanResult)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 20)

                        if let scannedImage = scannedQRCodeImage {
                            scannedImage
                                .resizable()
                                .frame(width: 200, height: 200)
                                .scaledToFit()
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                        }
                    }

                    // Text Input for QR Generation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("qr_code.text_input_label".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        ZStack {
                            TextEditor(text: $textInput)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                    }

                    // Generate QR Code Button
                    Button(action: {
                        generateQRCode(from: textInput)
                    }) {
                        HStack {
                            Image(systemName: "qrcode")
                                .foregroundColor(.green)
                            Text("qr_code.generate_button".localized)
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .disabled(textInput.isEmpty)

                    // Generated QR Code Display
                    if let qrCodeImage = qrCodeImage {
                        VStack(alignment: .center, spacing: 10) {
                            Text("qr_code.generated_qr".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            qrCodeImage
                                .resizable()
                                .frame(width: 200, height: 200)
                                .scaledToFit()
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                        }
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
                dismissButton: .default(Text("OK"))
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

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                qrCodeImage = Image(uiImage: UIImage(cgImage: cgImage))
            } else {
                alertItem = AlertItem(
                    title: "qr_code.error_title".localized,
                    message: "qr_code.generation_error".localized
                )
            }
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
            // Permission already granted, show the camera
            shouldShowCamera = true
        case .notDetermined:
            // Request permission
            Task {
                do {
                    let granted = try await AVCaptureDevice.requestAccess(for: .video)
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
                } catch {
                    await MainActor.run {
                        alertItem = AlertItem(
                            title: "qr_code.error_title".localized,
                            message: error.localizedDescription
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
    
    func makeUIViewController(context: Context) -> AVCaptureViewController {
        return AVCaptureViewController(
            scanResult: $scanResult,
            scannedQRCodeImage: $scannedQRCodeImage,
            presentationMode: presentationMode
        )
    }
    
    func updateUIViewController(_ uiViewController: AVCaptureViewController, context: Context) {}
}

// AVCapture View Controller
class AVCaptureViewController: UIViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

        // Set up the session directly since permission is handled in SwiftUI view
        setupSession(captureDevice: captureDevice)
    }

    private func setupSession(captureDevice: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error setting up capture session: \(error)")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)

        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)

        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle(NSLocalizedString("qr_code.close_camera", comment: ""), for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        // Setup constraints
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 120)
        ])

        captureSession.startRunning()
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
            let alert = UIAlertController(
                title: NSLocalizedString("qr_code.permission_error_title", comment: ""),
                message: NSLocalizedString("qr_code.permission_error_message", comment: ""),
                preferredStyle: .alert
            )

            // Add settings action if permission was denied
            if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("qr_code.open_settings", comment: "Open Settings"),
                    style: .default
                ) { _ in
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
            }

            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default
            ) { _ in
                self.presentationMode.wrappedValue.dismiss()
            })
            self.present(alert, animated: true)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension AVCaptureViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            AudioServicesPlaySystemSound(SystemSoundID(1005))
            scanResult.wrappedValue = stringValue

            // Stop capture session after successful scan
            captureSession.stopRunning()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}