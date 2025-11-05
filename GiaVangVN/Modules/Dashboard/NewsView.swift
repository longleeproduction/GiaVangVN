//
//  NewsView.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import SwiftUI
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var newsItems: [NewsResponse.NewsItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var selectedTab: NewsTab = .all

    enum NewsTab {
        case all, bookmarked
    }

    func fetchData() async {
        isLoading = true
        errorMessage = nil

        do {
            let request = NewsRequest(lang: "vi", page: 1, product: "cafef")
            let response = try await DashboardService.shared.fetchNews(request: request)

            if let data = response.data {
                newsItems = data.list
                currentPage = data.currentPage
                totalPages = data.totalPages
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching news: \(error)")
        }

        isLoading = false
    }

    func loadNextPage() async {
        guard currentPage < totalPages, !isLoading else { return }

        isLoading = true

        do {
            let request = NewsRequest(lang: "vi", page: currentPage + 1, product: "cafef")
            let response = try await DashboardService.shared.fetchNews(request: request)

            if let data = response.data {
                newsItems.append(contentsOf: data.list)
                currentPage = data.currentPage
                totalPages = data.totalPages
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading next page: \(error)")
        }

        isLoading = false
    }

    func refreshData() async {
        currentPage = 1
        newsItems = []
        await fetchData()
    }
}

struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var isPresentedSetting: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Loại tin", selection: $viewModel.selectedTab) {
                    Text("Tất cả").tag(NewsViewModel.NewsTab.all)
                    Text("Đã lưu").tag(NewsViewModel.NewsTab.bookmarked)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                if viewModel.selectedTab == .all {
                    allNewsView
                } else {
                    bookmarkedNewsView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AppHeaderView(title: "Tin tức")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentedSetting.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }

            }
            .fullScreenCover(isPresented: $isPresentedSetting) {
                SettingView()
            }
            .task {
                AdsManager.shared().showInterstitialAd()
                
                await viewModel.refreshData()
            }
        }
    }

    @ViewBuilder
    private var allNewsView: some View {
        if viewModel.isLoading && viewModel.newsItems.isEmpty {
            // Loading state
            VStack(spacing: 16) {
                ProgressView()
                Text("Đang tải tin tức...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.newsItems.isEmpty {
            // Error state
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Thử lại") {
                    Task {
                        await viewModel.refreshData()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.newsItems.isEmpty {
            // Empty state
            VStack(spacing: 16) {
                Image(systemName: "newspaper")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("Không có tin tức")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // News list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.newsItems) { newsItem in
                        NewsItemRow(newsItem: newsItem)
                            .onAppear {
                                // Load next page when reaching last item
                                if newsItem.id == viewModel.newsItems.last?.id {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                    }

                    // Loading indicator for next page
                    if viewModel.isLoading && !viewModel.newsItems.isEmpty {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Đang tải thêm...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }

    @ViewBuilder
    private var bookmarkedNewsView: some View {
        let bookmarkedNews = bookmarkManager.fetchBookmarkedNews()

        if bookmarkedNews.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "bookmark.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("Chưa có tin tức đã lưu")
                    .font(.body)
                    .foregroundColor(.secondary)
                Text("Nhấn vào biểu tượng bookmark để lưu tin tức")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(bookmarkedNews) { newsItem in
                        NewsItemRow(newsItem: newsItem)
                    }
                }
                .padding()
            }
        }
    }
}

struct NewsItemRow: View {
    let newsItem: NewsResponse.NewsItem
    @StateObject private var viewModel = NewsItemRowViewModel()
    @StateObject private var bookmarkManager = BookmarkManager.shared

    class NewsItemRowViewModel: ObservableObject {
        @Published var previewUrl: URL?
        @Published var isPresent: Bool = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image and Bookmark Button
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: newsItem.imgUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 200)
                .clipped()

                // Bookmark Button
                Button {
                    bookmarkManager.toggleBookmark(newsItem)
                } label: {
                    Image(systemName: bookmarkManager.isBookmarked(newsItem) ? "bookmark.fill" : "bookmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
                .padding(12)
            }

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(newsItem.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Description
                Text(newsItem.desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Time and Source
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(newsItem.date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(newsItem.source.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .onTapGesture {
            // Open news URL
            if let url = URL(string: newsItem.url) {
                viewModel.previewUrl = url
                viewModel.isPresent.toggle()
            }
        }
        .fullScreenCover(isPresented: $viewModel.isPresent) {
            if let url = viewModel.previewUrl {
                SFSafariView(url: url)
            } else {
                Button {
                    viewModel.isPresent.toggle()
                } label: {
                    Label("Trở về", systemImage: "arrow.uturn.backward")
                }
            }
        }
    }
}

#Preview {
    NewsView()
}
