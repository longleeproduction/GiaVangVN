//
//  SettingView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI
import SwifterSwift
import EmailComposer
import StoreKit
import AppTrackingTransparency

struct SettingView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var isSendFeedback = false
    @State private var isPresentPolicy = false
    @State private var isPresentTerm = false

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    SettingIntroView()
                                        
                    VStack(spacing: .zero) {
                        SettingItemView(title: "Chia sẽ ứng dụng", icon: "person.crop.circle.badge.plus", iconColor: Color.yellow) {
                            shareItems([AppConfig.shareMessage, AppConfig.appUrl])
                        }
                        
                        Divider()
                            .padding(.leading, 50)
                        
                        SettingItemView(title: "Đánh giá ứng dụng trên AppStore", icon: "star.circle", iconColor: Color.pink) {
                            requestRate()
                        }
                        
                        Divider()
                            .padding(.leading, 50)
                        
                        SettingItemView(title: "Gửi phản hồi, ý kiến", icon: "envelope.circle", iconColor: Color.green) {
                            isSendFeedback.toggle()
                        }
                        .emailComposer(isPresented: $isSendFeedback, emailData: EmailData(subject: AppConfig.mailSubject, recipients: [AppConfig.mailAddress], body: mailFeebackBody()))
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(spacing: .zero) {
                        SettingItemView(title: "Điều khoản sử dụng", icon: "text.book.closed", iconColor: Color.brown) {
                            isPresentTerm.toggle()
                        }
                        
                        Divider()
                            .padding(.leading, 50)
                        
                        SettingItemView(title: "Chính sách bảo mật", icon: "doc.append", iconColor: Color.purple) {
                            isPresentPolicy.toggle()
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    SettingsInfoRow(appName: appName(),
                                    appVersion: appVersion(),
                                    icon: UIApplication.shared.appIcon ?? UIImage())
                    
                }
                .padding(.horizontal)
                
            }.navigationTitle(Text("Cài đặt"))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }

                    }
                }
                .fullScreenCover(isPresented: $isPresentTerm) {
                    if let url = URL(string: AppConfig.termUrl) {
                        SFSafariView(url: url)
                    }
                }
                .fullScreenCover(isPresented: $isPresentPolicy) {
                    if let url = URL(string: AppConfig.policyUrl) {
                        SFSafariView(url: url)
                    }
                }
        }
    }
}

struct SettingItemView: View {
    
    var title: String = ""
    var icon: String = ""
    var iconColor: Color = Color.white
    var performAction: () -> Void
    
    var body: some View {
        Button(action: performAction) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 13))
                    .foregroundStyle(iconColor)
                    .padding(2.5)
                    .frame(width: 30, height: 30)
                
                Text(title.localized())
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
        }
    }
}


struct SettingsInfoRow: View {
    let appName: String
    let appVersion: String
    let icon: UIImage
    
    var body: some View {
        HStack {
            Image(uiImage: icon)
                .resizable()
                .frame(width: 50, height: 50)
                .scaledToFill()
                .background(.brown)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text("\(appName), Version \(appVersion)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                
                Text("Copyright © \(Date().year) \(appName) Ltd.\nAll rights reserved.")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }
}



// Util function

func requestIDFA() {
    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        
    })
}

func requestRate() {
    guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return
    }
    
    SKStoreReviewController.requestReview(in: currentScene)
}

func shareItems(_ items: [Any]) {
    let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
    guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        print("UNABLE TO GET CURRENT SCENE")
        return
    }
    activityController.popoverPresentationController?.sourceView = currentScene.windows.first?.rootViewController?.view
    activityController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
    
    currentScene.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
}

func mailFeebackBody() -> String {
        let version: String = appVersion()
        let appName: String = appName()
        return "\n\n\n\n\n\n\(appName), Version \(version)\nModel: \(UIDevice.current.modelName) (\(UIDevice.current.systemVersion))"
    }

func plistInfo() -> [String: Any] {
    var config: [String: Any]?
    
    if let infoPlistPath = Bundle.main.url(forResource: "Info", withExtension: "plist") {
        do {
            let infoPlistData = try Data(contentsOf: infoPlistPath)
            
            if let dict = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                config = dict
            }
        } catch {
            print(error)
        }
    }
    return config ?? [:]
}

func appVersion() -> String {
    let config : [String: Any] = plistInfo()
    let value: String? = config["CFBundleShortVersionString"] as? String
    return value ?? ""
}

func appName() -> String {
    let config : [String: Any] = plistInfo()
    let value: String? = config["CFBundleDisplayName"] as? String
    return value ?? ""
}
