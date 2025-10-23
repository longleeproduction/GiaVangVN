//
//  DashboardNewsView.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import SwiftUI
import Combine

@MainActor
class DashboardNewsViewModel: ObservableObject {
    @Published var newsItems: [NewsResponse.NewsItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1

    func fetchData() async {
        isLoading = true
        errorMessage = nil

        do {
            let request = NewsRequest(lang: "vi", page: currentPage, product: "cafef")
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
}

struct DashboardNewsView: View {
    @StateObject private var viewModel = DashboardNewsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Tin tức mới nhất")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                Spacer()
                
                NavigationLink {
                    NewsView()
                } label: {
                    Text("Xem thêm")
                        .padding(.horizontal)
                }
            }

            if viewModel.isLoading && viewModel.newsItems.isEmpty {
                // Loading state
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            } else if let errorMessage = viewModel.errorMessage, viewModel.newsItems.isEmpty {
                // Error state
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else if viewModel.newsItems.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "newspaper")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Không có tin tức")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                // News items horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.newsItems) { newsItem in
                            NewsItemCard(newsItem: newsItem)
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
                            ProgressView()
                                .frame(width: 280, height: 200)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

struct NewsItemCard: View {
    let newsItem: NewsResponse.NewsItem


    class NewsItemCardViewModel: ObservableObject {
        @Published var previewUrl: URL?
        @Published var isPresent: Bool = false
    }

    @StateObject private var viewModel = NewsItemCardViewModel()
    @StateObject private var bookmarkManager = BookmarkManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image with Bookmark Button
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
                .frame(width: 280, height: 160)
                .clipped()

                // Bookmark Button
                Button {
                    bookmarkManager.toggleBookmark(newsItem)
                } label: {
                    Image(systemName: bookmarkManager.isBookmarked(newsItem) ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
                .padding(8)
            }
            .frame(width: 280, height: 160)
            .cornerRadius(12)

            // Title
            Text(newsItem.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Description
            Text(newsItem.desc)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Time and Source
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(newsItem.date)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text(newsItem.source.uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .frame(width: 280)
        .padding(12)
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
    DashboardNewsView()
        .padding()
}
