import SwiftUI
import UIKit
import PDFKit
import UniformTypeIdentifiers
import Arithmetic

enum PDFGenerationError: LocalizedError {
    case noQuestions
    case emptyPDFData
    case fileWriteError

    var errorDescription: String? {
        switch self {
        case .noQuestions:
            return "math_bank.pdf.error.no_questions".localized
        case .emptyPDFData:
            return "math_bank.pdf.error.empty_data".localized
        case .fileWriteError:
            return "math_bank.pdf.error.file_write".localized
        }
    }
}
struct MathBankView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedDifficulty: DifficultyLevel = .level1
    @State private var selectedQuestionCount: Int = 20
    @State private var isGenerating = false
    @State private var alertItem: AlertItem? = nil
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    @State private var showingSaveOptions = false
    @State private var generatedPDFData: Data?

    private let questionCounts = [20, 40, 50, 80, 100]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    headerView
                    difficultySelectionView
                    questionCountSelectionView
                    generateButtonView
                }
                .padding()
            }
            .navigationTitle("math_bank.title".localized)
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
        }
        .alert(item: $alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: .default(Text("button.ok".localized))
            )
        }
        .actionSheet(isPresented: $showingSaveOptions) {
            ActionSheet(
                title: Text("math_bank.save_options.title".localized),
                message: Text("math_bank.save_options.message".localized),
                buttons: [
                    .default(Text("math_bank.save_to_files".localized)) {
                        showingDocumentPicker = true
                    },
                    .default(Text("math_bank.save_to_documents".localized)) {
                        saveToDocuments()
                    },
                    .default(Text("math_bank.share".localized)) {
                        showingShareSheet = true
                    },
                    .cancel(Text("button.cancel".localized))
                ]
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let pdfData = generatedPDFData {
                ShareSheet(items: [pdfData])
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            if let pdfData = generatedPDFData {
                DocumentPickerView(
                    pdfData: pdfData,
                    fileName: generateFileName(),
                    onSave: { success, pathOrError in
                        DispatchQueue.main.async {
                            if success {
                                let title = "math_bank.save_success_title".localized
                                let message = "math_bank.save_success".localized
                                if let path = pathOrError {
                                    self.alertItem = AlertItem(title: title, message: message + "\n" + path)
                                } else {
                                    self.alertItem = AlertItem(title: title, message: message)
                                }
                            } else {
                                let title = "alert.error_title".localized
                                var message = "math_bank.save_failed".localized
                                if let error = pathOrError {
                                    message += "\n" + "math_bank.pdf.error.prefix".localized + error
                                }
                                self.alertItem = AlertItem(title: title, message: message)
                            }
                        }
                    }
                )
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("math_bank.description".localized)
                .font(.adaptiveBody())
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var difficultySelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("math_bank.select_difficulty".localized)
                .font(.adaptiveHeadline())
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    Button(action: {
                        selectedDifficulty = difficulty
                    }) {
                        VStack(spacing: 8) {
                            Text(difficulty.localizedName)
                                .font(.adaptiveBody())
                                .foregroundColor(selectedDifficulty == difficulty ? .white : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedDifficulty == difficulty ? Color.orange : Color.gray.opacity(0.2))
                        .cornerRadius(.adaptiveCornerRadius)
                    }
                }
            }
        }
    }

    private var questionCountSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("math_bank.select_count".localized)
                .font(.adaptiveHeadline())
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(questionCounts, id: \.self) { count in
                    Button(action: {
                        selectedQuestionCount = count
                    }) {
                        Text("\(count)" + "math_bank.pdf.questions_suffix".localized)
                            .font(.adaptiveBody())
                            .foregroundColor(selectedQuestionCount == count ? .white : .primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedQuestionCount == count ? Color.orange : Color.gray.opacity(0.2))
                            .cornerRadius(.adaptiveCornerRadius)
                    }
                }
            }
        }
    }

    private var generateButtonView: some View {
        VStack(spacing: 20) {
            Button(action: generatePDF) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "doc.badge.plus")
                            .font(.title2)
                    }

                    Text(isGenerating ? "math_bank.generating".localized : "math_bank.generate".localized)
                        .font(.adaptiveHeadline())
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isGenerating ? Color.gray : Color.orange)
                .cornerRadius(.adaptiveCornerRadius)
            }
            .disabled(isGenerating)

            Text("math_bank.hint".localized)
                .font(.adaptiveCaption())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func generatePDF() {
        isGenerating = true
        print("math_bank.pdf.log.start_generating".localized)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 获取错题集
                print("math_bank.pdf.log.getting_wrong_questions".localized)
                let wrongQuestionManager = WrongQuestionManager()
                let wrongQuestions = wrongQuestionManager.getWrongQuestionsForLevel(selectedDifficulty, limit: selectedQuestionCount)
                print(String(format: "math_bank.pdf.log.got_wrong_questions".localized, "\(wrongQuestions.count)"))

                // 生成题目
                print("math_bank.pdf.log.generating_questions".localized)
                let questions = QuestionGenerator.generateQuestions(
                    difficultyLevel: selectedDifficulty,
                    count: selectedQuestionCount,
                    wrongQuestions: wrongQuestions
                )
                print(String(format: "math_bank.pdf.log.generated_questions".localized, "\(questions.count)"))

                // 验证题目不为空
                guard !questions.isEmpty else {
                    throw PDFGenerationError.noQuestions
                }

                // 生成PDF
                print("math_bank.pdf.log.start_pdf_generation".localized)
                let pdfData = MathBankPDFGenerator.generatePDF(
                    questions: questions,
                    difficulty: selectedDifficulty,
                    count: selectedQuestionCount
                )

                // 验证PDF数据不为空
                guard !pdfData.isEmpty else {
                    throw PDFGenerationError.emptyPDFData
                }

                print(String(format: "math_bank.pdf.log.pdf_success".localized, "\(pdfData.count)"))

                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.generatedPDFData = pdfData
                    self.showingSaveOptions = true
                }
            } catch {
                print(String(format: "math_bank.pdf.log.pdf_failed".localized, "\(error)"))
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.alertItem = AlertItem(title: "alert.error_title".localized, message: "math_bank.error".localized + ": \(error.localizedDescription)")
                }
            }
        }
    }

    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dateString = formatter.string(from: Date())
        return String(format: "math_bank.pdf.filename_template".localized, selectedDifficulty.localizedName, "\(selectedQuestionCount)", dateString)
    }

    private func saveToDocuments() {
        guard let pdfData = generatedPDFData else {
            print("math_bank.pdf.error.data_empty".localized)
            self.alertItem = AlertItem(title: "alert.error_title".localized, message: "math_bank.pdf.error.data_empty".localized)
            return
        }

        print(String(format: "math_bank.pdf.log.start_save_documents".localized, "\(pdfData.count)"))
        let fileName = generateFileName()
        print(String(format: "math_bank.pdf.log.filename".localized, fileName))

        let result = FileSaveHelper.saveToDocuments(data: pdfData, fileName: fileName)

        if result.success {
            print(String(format: "math_bank.pdf.save_success_with_path".localized, result.path ?? "Unknown path"))
            let title = "math_bank.save_success_title".localized
            var message = "math_bank.save_documents_success".localized
            if let path = result.path {
                message += "\n\(path)"
            }
            self.alertItem = AlertItem(title: title, message: message)
        } else {
            print("math_bank.pdf.save_failed_generic".localized)
            self.alertItem = AlertItem(title: "alert.error_title".localized, message: "math_bank.save_failed".localized)
        }
    }
}

// ShareSheet for sharing PDF
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Document Picker for saving files - 简化版本，直接使用ShareSheet
struct DocumentPickerView: UIViewControllerRepresentable {
    let pdfData: Data
    let fileName: String
    let onSave: (Bool, String?) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("math_bank.pdf.log.document_picker_system_share".localized)

        // 创建临时文件用于分享
        let tempURL = createTemporaryFile(data: pdfData, fileName: fileName)

        // 使用UIActivityViewController来分享文件
        let activityViewController = UIActivityViewController(
            activityItems: [tempURL],
            applicationActivities: nil
        )

        // 设置完成处理器
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("DocumentPicker: \(error)")
                    onSave(false, error.localizedDescription)
                } else if completed {
                    print("DocumentPicker: Share completed")
                    onSave(true, "math_bank.pdf.activity_share_success".localized)
                } else {
                    print("DocumentPicker: " + "math_bank.pdf.activity_user_cancelled".localized)
                    onSave(false, nil)
                }
            }
        }

        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }

    private func createTemporaryFile(data: Data, fileName: String) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(fileName)

        print("math_bank.pdf.log.create_temp_file".localized)
        print(String(format: "math_bank.pdf.log.temp_file_path".localized, tempURL.path))
        print(String(format: "math_bank.pdf.log.temp_file_data_size".localized, "\(data.count)"))

        do {
            // 如果临时文件已存在，先删除
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }

            // 写入临时文件
            try data.write(to: tempURL)
            print("math_bank.pdf.log.temp_file_success".localized)
        } catch {
            print(String(format: "math_bank.pdf.log.temp_file_failed".localized, "\(error)"))
        }

        return tempURL
    }
}

// File Save Helper
struct FileSaveHelper {
    static func saveToDocuments(data: Data, fileName: String) -> (success: Bool, path: String?) {
        print("math_bank.pdf.log.file_save_start".localized)
        print(String(format: "math_bank.pdf.log.file_save_data_size".localized, "\(data.count)"))
        print(String(format: "math_bank.pdf.log.file_save_filename".localized, fileName))

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("math_bank.pdf.log.file_save_no_documents".localized)
            return (false, nil)
        }

        print(String(format: "math_bank.pdf.log.file_save_documents_path".localized, documentsDirectory.path))

        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        print(String(format: "math_bank.pdf.log.file_save_full_path".localized, fileURL.path))

        do {
            // 确保Documents目录存在
            try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)

            // 如果文件已存在，先删除
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("math_bank.pdf.log.file_save_delete_existing".localized)
            }

            // 写入新文件
            try data.write(to: fileURL)
            print("math_bank.pdf.log.file_save_write_success".localized)

            // 验证文件是否真的被创建了
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                let fileSize = attributes[.size] as? Int64 ?? 0
                print(String(format: "math_bank.pdf.log.file_save_verify_success".localized, "\(fileSize)"))
                return (true, fileURL.path)
            } else {
                print("math_bank.pdf.log.file_save_verify_failed".localized)
                return (false, nil)
            }
        } catch {
            print(String(format: "math_bank.pdf.log.file_save_failed".localized, "\(error)"))
            print(String(format: "math_bank.pdf.log.file_save_error_detail".localized, error.localizedDescription))
            return (false, nil)
        }
    }

    static func getDocumentsDirectory() -> URL? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        print(String(format: "math_bank.pdf.log.documents_directory".localized, url?.path ?? "nil"))
        return url
    }
}

struct MathBankView_Previews: PreviewProvider {
    static var previews: some View {
        MathBankView()
            .environmentObject(LocalizationManager())
    }
}
