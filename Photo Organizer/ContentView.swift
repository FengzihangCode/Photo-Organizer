//
//  ContentView.swift
//  Photo Organizer
//
//  Created by DannyFeng
//

import SwiftUI

struct ContentView: View {
    @State private var sourceFolderURL: URL?
    @State private var destinationFolderURL: URL?
    @State private var sourceFolderPath: String = ""
    @State private var destinationFolderPath: String = ""
    @State private var selectedCategory: String = "日期"
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var confirmAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with Title and Buttons
            HStack {
                Text("Photo Organizer Desktop")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                HStack(spacing: 15) {
                    Button(action: openHelp) {
                        Image(systemName: "questionmark.circle")
                            .font(.title)
                    }

                    Button(action: openSettings) {
                        Image(systemName: "gear")
                            .font(.title)
                    }
                }
                .padding([.trailing])
            }
            .padding([.top, .leading])

            // Source Folder Selection
            HStack {
                Text("源文件夹")
                TextField("输入路径", text: $sourceFolderPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                Button(action: selectSourceFolder) {
                    Text("浏览")
                }
            }
            .padding([.leading, .trailing])

            // Destination Folder Selection
            HStack {
                Text("目标文件夹")
                TextField("输入路径", text: $destinationFolderPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
                Button(action: selectDestinationFolder) {
                    Text("浏览")
                }
            }
            .padding([.leading, .trailing])

            // Category Selection
            Picker("选择分类方式", selection: $selectedCategory) {
                Text("日期").tag("日期")
                Text("文件格式").tag("文件格式")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading])

            // Operation Buttons
            HStack {
                Button(action: {
                    confirmAction = organizePhotos
                    alertTitle = "确认分类"
                    alertMessage = "你确定要按 \(selectedCategory) 分类照片吗？"
                    showAlert = true
                }) {
                    Text("分类")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    confirmAction = undoLastOperation
                    alertTitle = "确认撤销"
                    alertMessage = "你确定要撤销上次操作吗？"
                    showAlert = true
                }) {
                    Text("撤销上次操作")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: openOperationHistory) {
                    Text("操作历史记录")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding([.leading])

            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .default(Text("确认"), action: {
                    confirmAction?()
                }),
                secondaryButton: .cancel()
            )
        }
        .padding()
    }

    private func selectSourceFolder() {
        let dialog = NSOpenPanel()
        dialog.title = "选择源文件夹"
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == .OK, let url = dialog.url {
            sourceFolderURL = url
            sourceFolderPath = url.path
        }
    }
    
    private func selectDestinationFolder() {
        let dialog = NSOpenPanel()
        dialog.title = "选择目标文件夹"
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == .OK, let url = dialog.url {
            destinationFolderURL = url
            destinationFolderPath = url.path
        }
    }

    private func organizePhotos() {
        guard let sourceURL = sourceFolderURL, let destinationURL = destinationFolderURL else {
            alertTitle = "路径错误"
            alertMessage = "请检查源文件夹和目标文件夹路径。"
            showAlert = true
            return
        }

        if selectedCategory == "日期" {
            organizePhotosByDate(sourceURL: sourceURL, destinationURL: destinationURL)
        } else if selectedCategory == "文件格式" {
            organizePhotosByFileType(sourceURL: sourceURL, destinationURL: destinationURL)
        }

        alertTitle = "分类完成"
        alertMessage = "照片已成功按 \(selectedCategory) 分类。"
        showAlert = true
    }

    private func organizePhotosByDate(sourceURL: URL, destinationURL: URL) {
        let fileManager = FileManager.default
        let photoURLs = try? fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
        
        for photoURL in photoURLs ?? [] {
            if let creationDate = try? photoURL.resourceValues(forKeys: [.creationDateKey]).creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: creationDate)
                
                let dateFolderURL = destinationURL.appendingPathComponent(dateString, isDirectory: true)
                if !fileManager.fileExists(atPath: dateFolderURL.path) {
                    try? fileManager.createDirectory(at: dateFolderURL, withIntermediateDirectories: true, attributes: nil)
                }
                
                let destinationPhotoURL = dateFolderURL.appendingPathComponent(photoURL.lastPathComponent)
                try? fileManager.moveItem(at: photoURL, to: destinationPhotoURL)
            }
        }
    }

    private func organizePhotosByFileType(sourceURL: URL, destinationURL: URL) {
        let fileManager = FileManager.default
        let photoURLs = try? fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        for photoURL in photoURLs ?? [] {
            let fileExtension = photoURL.pathExtension.lowercased().uppercased()  // 转换为大写
            let fileTypeFolderURL = destinationURL.appendingPathComponent(fileExtension, isDirectory: true)
            
            if !fileManager.fileExists(atPath: fileTypeFolderURL.path) {
                try? fileManager.createDirectory(at: fileTypeFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            let destinationPhotoURL = fileTypeFolderURL.appendingPathComponent(photoURL.lastPathComponent)
            try? fileManager.moveItem(at: photoURL, to: destinationPhotoURL)
        }
    }


    private func undoLastOperation() {
        guard let logURL = destinationFolderURL?.appendingPathComponent("Operation.txt") else { return }
        
        do {
            var logContent = try String(contentsOf: logURL)
            let logEntries = logContent.split(separator: "\n").map { String($0) }
            guard let lastEntry = logEntries.last else { return }
            
            let logComponents = lastEntry.split(separator: " ")
            guard logComponents.count >= 3 else { return }
            
            let operationType = logComponents[1]
            let filePath = logComponents.dropFirst(2).joined(separator: " ")
            
            switch operationType {
            case "Directory created:":
                if FileManager.default.fileExists(atPath: filePath) {
                    try FileManager.default.removeItem(atPath: filePath)
                    logContent = logContent.replacingOccurrences(of: lastEntry, with: "")
                    try logContent.write(to: logURL, atomically: true, encoding: .utf8)
                    alertTitle = "撤销成功"
                    alertMessage = "目录 \(filePath) 已移除。"
                } else {
                    alertTitle = "撤销失败"
                    alertMessage = "目录 \(filePath) 未找到。"
                }
            case "File moved:":
                let originalPath = URL(fileURLWithPath: destinationFolderPath).appendingPathComponent(filePath).path
                let newPath = URL(fileURLWithPath: sourceFolderPath).appendingPathComponent((originalPath as NSString).lastPathComponent).path
                if FileManager.default.fileExists(atPath: originalPath) {
                    try FileManager.default.moveItem(atPath: originalPath, toPath: newPath)
                    logContent = logContent.replacingOccurrences(of: lastEntry, with: "")
                    try logContent.write(to: logURL, atomically: true, encoding: .utf8)
                    alertTitle = "撤销成功"
                    alertMessage = "文件 \(filePath) 已移回源文件夹。"
                } else {
                    alertTitle = "撤销失败"
                    alertMessage = "文件 \(filePath) 未找到。"
                }
            default:
                alertTitle = "撤销失败"
                alertMessage = "未知操作类型。"
            }
        } catch {
            alertTitle = "错误"
            alertMessage = "无法读取操作日志。"
            showAlert = true
        }
    }

    private func openOperationHistory() {
        guard let logURL = destinationFolderURL?.appendingPathComponent("Operation.txt") else {
            alertTitle = "操作历史记录未找到"
            alertMessage = "无法找到 Operation.txt 文件，请检查目标文件夹路径。"
            showAlert = true
            return
        }

        if FileManager.default.fileExists(atPath: logURL.path) {
            NSWorkspace.shared.open(logURL)
        } else {
            alertTitle = "操作历史记录未找到"
            alertMessage = "无法找到 Operation.txt 文件，请检查目标文件夹路径。"
            showAlert = true
        }
    }

    private func openHelp() {
        // 打开帮助文档或显示帮助信息
        alertTitle = "帮助"
        alertMessage = "这里可以显示帮助信息或打开帮助文档的链接。"
        showAlert = true
    }

    private func openSettings() {
        // 打开设置页面或显示设置相关内容
        alertTitle = "设置"
        alertMessage = "这里可以显示设置选项或打开设置页面。"
        showAlert = true
    }
}
