//
//  SettingIntroView.swift
//  GiaVangVN
//
//  Created by ORL on 4/11/25.
//

import SwiftUI
import Kingfisher

// MARK: - App Intro Model
struct AppIntro: Identifiable, Codable {
    let id = UUID()
    let appstore_url: String
    let caption: String
    let description: String
    let enabled: Bool
    let image_url: String
    let appicon_url: String
    let title: String
    let bundleId: String?

    enum CodingKeys: String, CodingKey {
        case appstore_url, caption, description, enabled
        case image_url, appicon_url, title, bundleId
    }
}

struct SettingIntroView: View {
    @State private var currentPage = 0

    // Hardcoded app intro data
    private let apps: [AppIntro] = [
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id6482849425",
            caption: "New App",
            description: "Music Downloader Play Music Offline",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1ij5hqnJyF1bvsPFlX32Zgu4v0Pc2--IO",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/41/2f/03/412f03e6-a897-88d7-a045-ea8558f113f9/AppIcon-0-0-1x_U007epad-0-85-220.jpeg/540x540bb.jpg",
            title: "Volume Booster - Loud Speaker",
            bundleId: nil
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id6478867245",
            caption: "New App",
            description: "Downloader • Player • Manager • Browser",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1pDE_TKWzrqlUhn7YmluYwAHaZZK82Qb-",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/a8/bf/ed/a8bfed3f-47e0-2694-dc14-ec855cc5ba42/AppIcon-0-0-1x_U007epad-0-0-85-220.jpeg/540x540bb.jpg",
            title: "Offline Files Download Manager",
            bundleId: nil
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id6450380621",
            caption: "New App Update",
            description: "AI Effect. AI Removal. AI Edit",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1MuvWFzgWd9ZLrvIZdLJvf-4eWPSIW4AF",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/96/65/b5/9665b508-6ac2-b3e4-421a-374642f61494/AppIcon-0-0-1x_U007epad-0-0-85-220.png/540x540bb.jpg",
            title: "PixeAI - AI Video Photo Editor",
            bundleId: nil
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id1616481958",
            caption: "New App Update",
            description: "Go on a Randonauting Advanture.",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=10S1pkFzTpQX46HK6uj2Ses8vL3Zdx7Oe",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/68/d3/26/68d326a6-3e93-eb47-b6f5-bdc8ac94b9e6/AppIcon-1x_U007emarketing-0-7-0-85-220.png/540x540bb.jpg",
            title: "Randonauting Location Discover",
            bundleId: "com.orientpro.randonauting"
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id6474580317",
            caption: "New App Update",
            description: "ID Passport CV Resume Photo.",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1Yqcy7Nm1R5pei1hfJbZIZ4AY8Dga2lDO",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/3a/7a/8f/3a7a8f33-2f35-1da9-e1fa-3f584659e9a4/AppIcon-0-0-1x_U007epad-0-0-85-220.png/540x540bb.jpg",
            title: "ID Passport Photo Booth AI",
            bundleId: nil
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id1614396365",
            caption: "New App Update",
            description: "Cartoon Photo - AI Cartoon",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1I1L-xErsZXSoQzlbMw09IeVUusTYK1Xw",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/2f/e6/a0/2fe6a048-8e46-229e-1ece-1c0fa0c08d05/AppIcon-1x_U007emarketing-0-7-0-85-220.png/540x540bb.jpg",
            title: "Cartoon Photo - AI Cartoon",
            bundleId: nil
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id1615572010",
            caption: "New App Update",
            description: "Compress Photo & Save Space",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1piIi2WPzGCHQugVLvp9CCay3bxqBvUcn",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/6a/53/90/6a5390db-5e03-b563-d83b-e5ba0f63460d/AppIcon-1x_U007emarketing-0-7-0-85-220-0.png/540x540bb.jpg",
            title: "Compress Photo & Save Space",
            bundleId: nil
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id1615883784",
            caption: "New App Update",
            description: "Compress Videos - Shrink Video",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1hS6jW6TThM848IfygDBUlW_yNNPdbc8f",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/af/bc/f6/afbcf612-6331-7a1f-ffe7-de324e094741/AppIcon-1x_U007emarketing-0-7-0-85-220-0.png/540x540bb.jpg",
            title: "Compress Videos - Shrink Video",
            bundleId: nil
        ),
        AppIntro(
            appstore_url: "https://apps.apple.com/app/id6484267417",
            caption: "New App",
            description: "Transfer.Backup.Share Contacts",
            enabled: true,
            image_url: "https://drive.google.com/uc?export=view&id=1t0tEoa_xFqFSG8GBtD_MowQQS1RqeGrv",
            appicon_url: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/e3/7e/f5/e37ef519-ff14-3940-2e51-d51548c7b863/AppIcon-0-0-1x_U007epad-0-0-85-220.png/540x540bb.jpg",
            title: "Contacts Backup. Restore.Clean",
            bundleId: nil
        )
    ]

    var enabledApps: [AppIntro] {
        apps.filter { $0.enabled }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab View Slider
            TabView(selection: $currentPage) {
                ForEach(Array(enabledApps.enumerated()), id: \.element.id) { index, app in
                    AppIntroCard(app: app)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }.frame(height: 240)
    }
}

// MARK: - App Intro Card
struct AppIntroCard: View {
    let app: AppIntro

    var body: some View {
        // Screenshot with overlaid app info
        ZStack(alignment: .bottom) {
            // Background Screenshot Image
            KFImage(URL(string: app.image_url))
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
                .resizable()
//                .aspectRatio(16/9, contentMode: .fill)
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 240)
                .clipped()

            // Gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )

            // App Info overlaid at bottom
            HStack(spacing: 12) {
                // App Icon
                KFImage(URL(string: app.appicon_url))
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    // Caption Badge
                    Text(app.caption)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)

                    // Title
                    Text(app.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    // Description
                    Text(app.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(16)
        .shadow(radius: 5)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: app.appstore_url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    SettingIntroView()
}

