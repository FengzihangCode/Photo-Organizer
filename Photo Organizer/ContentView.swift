//
//  ContentView.swift
//  Photo Organizer
//
//  Created by feng on 8/17/24.
//

import SwiftUI

struct ContentView: View {
    @State private var sourceFolderURL: URL?
    @State private var destinationFolderURL: URL?
    @State private var selectedCategory: String = "日期" // 分类方式（日期或文件格式）

    var body: some View {
        ZStack {
            // 背景颜色
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all) // 使背景颜色覆盖整个视图
            
            VStack(spacing: 20) {
                // 选择源文件夹按钮
                Button(action: selectSourceFolder) {
                    Text("选择源文件夹")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if let sourceFolderURL = sourceFolderURL {
                    Text("源文件夹: \(sourceFolderURL.path)")
                        .padding()
                }
                
                // 选择目标文件夹按钮
                Button(action: selectDestinationFolder) {
                    Text("选择目标文件夹")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if let destinationFolderURL = destinationFolderURL {
                    Text("目标文件夹: \(destinationFolderURL.path)")
                        .padding()
                }
                
                // 分类选择
                Picker("选择分类方式", selection: $selectedCategory) {
                    Text("日期").tag("日期")
                    Text("文件格式").tag("文件格式")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 执行分类按钮
                Button(action: organizePhotos) {
                    Text("开始分类")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
    
    private func selectSourceFolder() {
        let dialog = NSOpenPanel()
        dialog.title = "选择源文件夹"
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == .OK {
            sourceFolderURL = dialog.url
        }
    }
    
    private func selectDestinationFolder() {
        let dialog = NSOpenPanel()
        dialog.title = "选择目标文件夹"
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == .OK {
            destinationFolderURL = dialog.url
        }
    }

    private func organizePhotos() {
        if selectedCategory == "日期" {
            organizePhotosByDate()
        } else if selectedCategory == "文件格式" {
            organizePhotosByFileType()
        }
    }
    
    private func organizePhotosByDate() {
        guard let sourceURL = sourceFolderURL, let destinationURL = destinationFolderURL else { return }

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
    
    private func organizePhotosByFileType() {
        guard let sourceURL = sourceFolderURL, let destinationURL = destinationFolderURL else { return }

        let fileManager = FileManager.default
        let photoURLs = try? fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        for photoURL in photoURLs ?? [] {
            let fileExtension = photoURL.pathExtension.lowercased()
            let fileTypeFolderURL = destinationURL.appendingPathComponent(fileExtension, isDirectory: true)
            if !fileManager.fileExists(atPath: fileTypeFolderURL.path) {
                try? fileManager.createDirectory(at: fileTypeFolderURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            let destinationPhotoURL = fileTypeFolderURL.appendingPathComponent(photoURL.lastPathComponent)
            try? fileManager.moveItem(at: photoURL, to: destinationPhotoURL)
        }
    }
}

#Preview {
    ContentView()
}
