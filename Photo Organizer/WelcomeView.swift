//
//  WelcomeView.swift
//  Photo Organizer
//
//  Created by feng on 8/20/24.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("欢迎使用 Photo Organizer!")
                .font(.largeTitle)
                .padding()

            Button("开始使用") {
                isPresented = false // 关闭欢迎页面
            }
            .padding()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isPresented: .constant(true)) // 预览时使用常量绑定
    }
}
