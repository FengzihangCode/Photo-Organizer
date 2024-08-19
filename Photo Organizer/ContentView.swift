//
//  ContentView.swift
//  Photo Organizer
//
//  Created by DannyFeng
//

import SwiftUI
import Foundation
import Cocoa

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
    @State private var isSidebarVisible: Bool = true
    @State private var currentPage: String = "主页" // Track current page
    @State private var loggingEnabled: Bool = false
    @State private var wallpaperImage: NSImage?

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            if isSidebarVisible {
                VStack {
                    Spacer()
                    
                    SidebarButton(label: "主页", systemImage: "house", isSelected: currentPage == "主页") {
                        currentPage = "主页"
                    }
                    SidebarButton(label: "帮助", systemImage: "questionmark.circle", isSelected: currentPage == "帮助") {
                        currentPage = "帮助"
                    }
                    SidebarButton(label: "设置", systemImage: "gear", isSelected: currentPage == "设置") {
                        currentPage = "设置"
                    }
                    
                    Spacer()
                }
                .frame(width: 250)
                .background(Color.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all)
            }

            // Main Content
            VStack(alignment: .leading, spacing: 20) {
                // Header with Title and Sidebar Button
                HStack {
                    Button(action: {
                        withAnimation {
                            isSidebarVisible.toggle()
                        }
                    }) {
                        Image(systemName: "sidebar.left")
                            .font(.title)
                    }

                    // Change title based on the selected page
                    Text(currentPage == "主页" ? "Photo Organizer Desktop" : currentPage == "设置" ? "设置" : "帮助")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()
                }
                .padding([.top, .leading], 20)

                // Main content based on current page
                if currentPage == "主页" {
                    VStack(alignment: .leading, spacing: 20) {
                        // Source Folder Selection
                        HStack {
                            Text("源文件夹")
                                .frame(width: 67, alignment: .leading)
                            TextField("输入或选择路径", text: $sourceFolderPath)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.trailing, 1)
                            Button(action: selectSourceFolder) {
                                Text("浏览")
                            }
                        }

                        // Destination Folder Selection
                        HStack {
                            Text("目标文件夹")
                                .frame(width: 67, alignment: .leading)
                            TextField("输入或选择路径", text: $destinationFolderPath)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.trailing, 1)
                            Button(action: selectDestinationFolder) {
                                Text("浏览")
                            }
                        }

                        // Category Selection
                        Picker("选择分类方式", selection: $selectedCategory) {
                            Text("日期").tag("日期")
                            Text("文件格式").tag("文件格式")
                            Text("元数据").tag("元数据")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding([.leading, .trailing], 20)

                        // Operation Buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                confirmAction = organizePhotos
                                alertTitle = "确认分类"
                                alertMessage = "你确定要按 \(selectedCategory) 分类照片吗？"
                                showAlert = true
                            }) {
                                Text("分类")
                                    .padding()
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
                                    .cornerRadius(8)
                            }
                            
                            Button(action: openOperationHistory) {
                                Text("操作历史记录")
                                    .padding()
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding([.leading, .trailing], 20)
                } else if currentPage == "设置" {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("设置")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 20)

                            // 关于 Section
                            Text("关于")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)

                            HStack {
                                Image("AppIcon")
                                    .resizable()
                                    .frame(width: 64, height: 64)
                                    .padding(.trailing, 10)
                                VStack(alignment: .leading) {
                                    Text("版本: 1.0.0")
                                    Text("作者: DannyFeng")
                                    Text("开源项目: https://github.com/FengzihangCode/Photo-Organizer")
                                    Button(action: checkForUpdates) {
                                        Text("检查更新")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.bottom, 20)

                            // 功能 Section
                            Text("功能")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)

                            Toggle(isOn: $loggingEnabled) {
                                Text("启用操作日志记录")
                            }

                            Picker("默认分类方式", selection: $selectedCategory) {
                                Text("日期").tag("日期")
                                Text("文件格式").tag("文件格式")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 20)

                            // 个性化 Section
                            Text("个性化")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            Section(header: Text("个性化").font(.headline)) {
                                Button(action: {
                                    selectWallpaperImage()
                                }) {
                                    Text("上传壁纸照片")
                                }
                            }

                            // Add any personalization settings here

                            Spacer()
                        }
                        .padding()
                    }
                }
                else if currentPage == "帮助" {
                    Text("帮助内容")
                        .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .default(Text("确认"), action: confirmAction ?? {}),
                secondaryButton: .cancel()
            )
        }
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
                do {
                    try fileManager.moveItem(at: photoURL, to: destinationPhotoURL)
                } catch {
                    print("Failed to move photo: \(error)")
                }
            }
        }
        
        // Log the operation if logging is enabled
        if loggingEnabled {
            logOperation(description: "Photos organized by date")
        }
    }

    private func organizePhotosByFileType(sourceURL: URL, destinationURL: URL) {
        let fileManager = FileManager.default
        let photoURLs = try? fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: [.typeIdentifierKey], options: [.skipsHiddenFiles])
        
        for photoURL in photoURLs ?? [] {
            if (try? photoURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier) != nil {
                let fileExtension = (photoURL.pathExtension as NSString).uppercased
                let typeFolderURL = destinationURL.appendingPathComponent(fileExtension, isDirectory: true)
                
                if !fileManager.fileExists(atPath: typeFolderURL.path) {
                    try? fileManager.createDirectory(at: typeFolderURL, withIntermediateDirectories: true, attributes: nil)
                }
                
                let destinationPhotoURL = typeFolderURL.appendingPathComponent(photoURL.lastPathComponent)
                do {
                    try fileManager.moveItem(at: photoURL, to: destinationPhotoURL)
                } catch {
                    print("Failed to move photo: \(error)")
                }
            }
        }
        
        // Log the operation if logging is enabled
        if loggingEnabled {
            logOperation(description: "Photos organized by file type")
        }
    }
    
    private func saveWallpaperImage(_ image: NSImage) {
        let fileManager = FileManager.default
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let wallpaperURL = appSupportURL.appendingPathComponent("Wallpaper.png")
            
            if let imageData = image.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: imageData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                try? pngData.write(to: wallpaperURL)
            }
        }
    }

    
    private func selectWallpaperImage() {
        let dialog = NSOpenPanel()
        dialog.title = "选择壁纸照片"
        dialog.allowedContentTypes = [.image] // 允许的文件类型为图片
        
        if dialog.runModal() == .OK, let url = dialog.url {
            if let image = NSImage(contentsOf: url) {
                wallpaperImage = image
                // 保存到用户缓存或应用目录
                saveWallpaperImage(image)
            }
        }
    }

    
    private func undoLastOperation() {
        // Logic to undo the last operation based on the logged information
    }

    private func openOperationHistory() {
        // Logic to display the operation history
    }

    struct SidebarButton: View {
        var label: String
        var systemImage: String
        var isSelected: Bool
        var action: () -> Void
    
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                        .frame(width: 24)
                    Text(label)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .blue : .primary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        }
    }
    
    private func checkForUpdates() {
        guard let url = URL(string: "https://api.github.com/repos/FengzihangCode/Photo-Organizer/releases/latest") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let latestVersion = json["tag_name"] as? String {
                        DispatchQueue.main.async {
                            compareVersions(latestVersion: latestVersion)
                        }
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                }
            } else if let error = error {
                print("Error fetching update: \(error)")
            }
        }
        task.resume()
    }

    private func compareVersions(latestVersion: String) {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

        if latestVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
            showAlert(title: "更新可用", message: "有新的版本 \(latestVersion) 可用。请访问 GitHub 下载最新版本。")
        } else {
            showAlert(title: "已是最新版本", message: "你已经安装了最新版本 \(currentVersion)。")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
    
    private func logOperation(description: String) {
        // Logic to log the operation
    }
}
struct WallpaperUploadView: View {
    @State private var wallpaperImage: NSImage?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("个性化")
                .font(.headline)
                .padding(.bottom, 10)
            
            Button(action: selectWallpaperImage) {
                Text("上传壁纸照片")
            }
            .padding()
            
            if let image = wallpaperImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
    }
    
    
    private func selectWallpaperImage() {
        let dialog = NSOpenPanel()
        dialog.title = "选择壁纸图片"
        dialog.canChooseFiles = true
        dialog.allowedContentTypes = [.image]
        
        if dialog.runModal() == .OK, let url = dialog.url {
            if let image = NSImage(contentsOf: url) {
                wallpaperImage = image
                saveWallpaperImage(image)
            }
        }
    }
    
    private func saveWallpaperImage(_ image: NSImage) {
        let fileManager = FileManager.default
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let wallpaperURL = appSupportURL.appendingPathComponent("Wallpaper.png")
            
            if let imageData = image.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: imageData),
               let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                try? pngData.write(to: wallpaperURL)
            }
        }
    }
    
    private func loadWallpaperImage() {
        let fileManager = FileManager.default
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let wallpaperURL = appSupportURL.appendingPathComponent("Wallpaper.png")
            if let image = NSImage(contentsOf: wallpaperURL) {
                wallpaperImage = image
            }
        }
    }
    
    
}
