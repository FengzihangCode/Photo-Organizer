//
//  ContentView.swift
//  Photo Organizer
//
//  Created by DannyFeng
//

import SwiftUI
import CloudKit //iCloud

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
    @State private var selectedThemeColor: Color = .blue // 添加用于存储主题颜色的状态
    @State private var presetColors: [Color] = [.blue, .red, .green, .orange, .purple]
    @State private var selectedSourceFolder: URL? = nil
    @State private var imagePreviews: [NSImage] = []
    @State private var sourceFolder: URL?
    @State private var photoPreviews: [NSImage] = []
    @State private var previewMessage: String = "未选定源文件夹"
    
    let supportedFormats: [String] = ["jpg", "jpeg", "png", "heic", "bmp", "tiff"] // 可预览的格式
    let rawFormats: [String] = ["arw", "dng", "cr2", "nef"] // RAW格式应当是无法被直接预览的，因而此列表为不可预览的格式
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            if isSidebarVisible {
                VStack {
                    Spacer()
                    
                    SidebarButton(label: "主页", systemImage: "house", isSelected: currentPage == "主页", themeColor: selectedThemeColor) {
                        currentPage = "主页"
                    }
                    SidebarButton(label: "接力", systemImage: "ipad.and.iphone", isSelected: currentPage == "接力", themeColor: selectedThemeColor) {
                        currentPage = "接力"
                    }
                    SidebarButton(label: "帮助", systemImage: "questionmark.circle", isSelected: currentPage == "帮助", themeColor: selectedThemeColor) {
                        currentPage = "帮助"
                    }
                    SidebarButton(label: "设置", systemImage: "gear", isSelected: currentPage == "设置", themeColor: selectedThemeColor) {
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
                    Text(currentPage == "主页" ? "Photo Organizer Desktop" :
                         currentPage == "设置" ? "设置" :
                         currentPage == "接力" ? "接力" :
                         currentPage == "帮助" ? "帮助" :
                         "unknown")

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
                            TextField("输入或选择路径", text: $sourceFolderPath, onCommit: {
                                sourceFolder = URL(fileURLWithPath: sourceFolderPath)
                                loadPhotos(from: sourceFolder!)
                            })
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
                            
                        }
                        
                        VStack {
                            // 预览框
                            if photoPreviews.isEmpty {
                                Text(previewMessage)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(photoPreviews, id: \.self) { image in
                                            Image(nsImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        .frame(height: 150) // 设置预览框的高度
                        .background(Color.secondary.opacity(0.1)) // 设置背景颜色
                        .cornerRadius(8)
                        .padding([.leading, .trailing], 20)
                        
                    }
                    .padding([.leading, .trailing], 20)
                } else if currentPage == "接力" {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("接力功能允许您将macOS的内容无缝同步到iPhone或iPad上，并在这些设备上继续工作")
                        RelayView(folders: ["文件夹1", "文件夹2", "文件夹3"]) // 传递示例文件夹列表
                    }
                    .padding()
                }

                else if currentPage == "设置" {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // 关于 Section
                            Text("关于")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            
                            HStack {
                                Image("AppImage")
                                    .resizable()
                                    .frame(width: 128, height: 128)
                                    .padding(.trailing, 10)
                                VStack(alignment: .leading) {
                                    Text("Photo Organizer V1.7.0 Build 1")
                                    Text("作者: DannyFeng")
                                    Text("开源项目: https://github.com/FengzihangCode/Photo-Organizer")
                                    Button(action: checkForUpdates) {
                                        Text("检查更新")
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // 功能 Section
                            Text("功能")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            
                            Picker("默认分类方式", selection: $selectedCategory) {
                                Text("日期").tag("日期")
                                Text("文件格式").tag("文件格式")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 20)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                // 个性化 Section
                                Text("个性化")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 10)
                                
                                Section(header: Text("选择主题色").font(.headline)) {
                                    HStack {
                                        // Display preset colors
                                        ForEach(presetColors, id: \.self) { color in
                                            ZStack {
                                                Circle()
                                                    .fill(color)
                                                    .frame(width: 44, height: 44)
                                                    .onTapGesture {
                                                        selectedThemeColor = color
                                                    }
                                                
                                                if selectedThemeColor == color {
                                                    Image(systemName: "checkmark.circle")
                                                        .foregroundColor(.white)
                                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                                }
                                            }
                                        }
                                        
                                        // Display color picker
                                        ColorPicker("", selection: $selectedThemeColor)
                                            .labelsHidden()
                                    }
                                }
                            }
                            .padding()
                            
                            // Add any personalization settings here
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                else if currentPage == "帮助" {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("感谢您使用Photo Organizer！")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("在这里您可以找到有关Photo Organizer的帮助信息")
                        Text("**该App目前正处于开发阶段，因此部分功能尚未实现，应用程序也不一定能完全按预期运行**")
                        Text("遇到问题，请在GitHub提交Issue")
                        Text("如果您需要更多帮助，请访问我们的 [GitHub页面](https://github.com/FengzihangCode/Photo-Organizer) 或联系开发者以了解更多详细信息")
                    }
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
    
    // 选择源文件夹的函数
    func selectSourceFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            if let url = panel.urls.first {
                sourceFolder = url
                sourceFolderPath = url.path // 更新路径文本框
                loadPhotos(from: url)
            }
        }
    }
    
    // 加载照片并检查预览条件
    func loadPhotos(from folderURL: URL) {
        let fileManager = FileManager.default
        let photoURLs = (try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil))?.filter { url in
            let fileExtension = url.pathExtension.lowercased()
            return supportedFormats.contains(fileExtension) || rawFormats.contains(fileExtension)
        } ?? []
        
        if photoURLs.isEmpty {
            previewMessage = "选定的文件夹内没有照片"
            photoPreviews = []
        } else if photoURLs.allSatisfy({ rawFormats.contains($0.pathExtension.lowercased()) }) {
            previewMessage = "照片格式不支持预览"
            photoPreviews = []
        } else {
            previewMessage = ""
            photoPreviews = photoURLs.compactMap { url in
                if supportedFormats.contains(url.pathExtension.lowercased()) {
                    return NSImage(contentsOf: url)
                } else {
                    return nil
                }
            }
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
            destinationFolderPath = url.path // 更新路径文本框
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
        
    }
    
    private func organizePhotosByFileType(sourceURL: URL, destinationURL: URL) {
        let fileManager = FileManager.default
        let photoURLs = try? fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: [.typeIdentifierKey], options: [.skipsHiddenFiles])
        
        for photoURL in photoURLs ?? [] {
            if (try? photoURL.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier) != nil {
                let fileExtension = photoURL.pathExtension.uppercased()
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
    }
    
    struct SidebarButton: View {
        var label: String
        var systemImage: String
        var isSelected: Bool
        var themeColor: Color // 参数用于接收主题颜色
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                        .frame(width: 24)
                        .foregroundColor(isSelected ? themeColor : .primary)
                    Text(label)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? themeColor : .primary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            .background(isSelected ? themeColor.opacity(0.2) : Color.clear)
        }
    }
    
    private func checkForUpdates() {
        if let url = URL(string: "https://github.com/FengzihangCode/Photo-Organizer/releases") {
            NSWorkspace.shared.open(url)
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
    
    // Function to load images from the selected source folder
    private func loadImages() {
        guard let sourceFolderURL = sourceFolderURL else {
            return
        }
        
        let fileManager = FileManager.default
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff"]
        imagePreviews = []
        
        if let photoURLs = try? fileManager.contentsOfDirectory(at: sourceFolderURL, includingPropertiesForKeys: nil) {
            for url in photoURLs where imageExtensions.contains(url.pathExtension.lowercased()) {
                if let image = NSImage(contentsOf: url) {
                    imagePreviews.append(image)
                }
            }
        }
    }
    
    
    struct PhotoPreviewView: View {
        var images: [NSImage] // 图片数组
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 10) {
                    ForEach(images, id: \.self) { image in
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()  // 保持长宽比
                            .frame(height: 100)  // 可以调整高度，根据需要设置
                            .cornerRadius(8)  // 可选的，给图片加个圆角
                    }
                }
                .padding()
            }
            .background(Color.gray.opacity(0.2))  // 预览框背景颜色
            .cornerRadius(10)
            .padding()
        }
    }
    
    struct RelayView: View {
        @State private var selectedFolders: [String] = []
        var folders: [String] // 新增的文件夹列表参数
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("您可以在下面选择需要同步到其他设备的文件夹。*开发版本中仅作为示范")
                
                List(folders, id: \.self) { folder in
                    HStack {
                        Text(folder)
                        Spacer()
                        if selectedFolders.contains(folder) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let index = selectedFolders.firstIndex(of: folder) {
                            selectedFolders.remove(at: index)
                        } else {
                            selectedFolders.append(folder)
                        }
                    }
                }
                
                HStack {
                    Button("同步到iCloud") {
                        // uploadFileToiCloud(fileURL: URL)
                    }
                    Button("推送到其他设备") {
                        // 推送到其他设备的逻辑
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }


    // 具体的同步和推送功能在这里实现
    func uploadFileToiCloud(fileURL: URL) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        
        let record = CKRecord(recordType: "PhotoOrganizer")
        record["fileName"] = fileURL.lastPathComponent as CKRecordValue
        
        let fileAsset = CKAsset(fileURL: fileURL)
        record["file"] = fileAsset
        
        privateDatabase.save(record) { record, error in
            if let error = error {
                print("Error uploading file: \(error.localizedDescription)")
            } else {
                print("File uploaded successfully!")
            }
        }
    }


    func pushToOtherDevices(folders: [String]) {
        // 推送到其他设备的代码
        }
    }

    struct CheckBoxView: View {
        @Binding var isChecked: Bool

        var body: some View {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .onTapGesture {
                    isChecked.toggle()
                }
        }
    }

       
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
