//
//  BookmarkManager.swift
//  GiaVangVN
//
//  Created by ORL
//

import Foundation
import CoreData
import Combine

@MainActor
class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()

    @Published var bookmarkedNewsURLs: Set<String> = []

    private let viewContext: NSManagedObjectContext

    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
        loadBookmarkedURLs()
    }

    // MARK: - Public Methods

    /// Check if a news item is bookmarked
    func isBookmarked(_ newsItem: NewsResponse.NewsItem) -> Bool {
        return bookmarkedNewsURLs.contains(newsItem.url)
    }

    /// Toggle bookmark status for a news item
    func toggleBookmark(_ newsItem: NewsResponse.NewsItem) {
        if isBookmarked(newsItem) {
            removeBookmark(newsItem)
        } else {
            addBookmark(newsItem)
        }
    }

    /// Add a news item to bookmarks
    func addBookmark(_ newsItem: NewsResponse.NewsItem) {
        // Check if already bookmarked
        if isBookmarked(newsItem) {
            return
        }

        let bookmark = BookmarkedNews(context: viewContext)
        bookmark.title = newsItem.title
        bookmark.desc = newsItem.desc
        bookmark.imgUrl = newsItem.imgUrl
        bookmark.url = newsItem.url
        bookmark.date = newsItem.date
        bookmark.source = newsItem.source
        bookmark.bookmarkedAt = Date()

        saveContext()
        bookmarkedNewsURLs.insert(newsItem.url)
    }

    /// Remove a news item from bookmarks
    func removeBookmark(_ newsItem: NewsResponse.NewsItem) {
        let fetchRequest: NSFetchRequest<BookmarkedNews> = BookmarkedNews.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", newsItem.url)

        do {
            let results = try viewContext.fetch(fetchRequest)
            for bookmark in results {
                viewContext.delete(bookmark)
            }
            saveContext()
            bookmarkedNewsURLs.remove(newsItem.url)
        } catch {
            print("Error removing bookmark: \(error)")
        }
    }

    /// Fetch all bookmarked news items
    func fetchBookmarkedNews() -> [NewsResponse.NewsItem] {
        let fetchRequest: NSFetchRequest<BookmarkedNews> = BookmarkedNews.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BookmarkedNews.bookmarkedAt, ascending: false)]

        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.map { bookmark in
                NewsResponse.NewsItem(
                    title: bookmark.title ?? "",
                    desc: bookmark.desc ?? "",
                    imgUrl: bookmark.imgUrl ?? "",
                    url: bookmark.url ?? "",
                    date: bookmark.date ?? "",
                    source: bookmark.source ?? ""
                )
            }
        } catch {
            print("Error fetching bookmarked news: \(error)")
            return []
        }
    }

    // MARK: - Private Methods

    private func loadBookmarkedURLs() {
        let fetchRequest: NSFetchRequest<BookmarkedNews> = BookmarkedNews.fetchRequest()

        do {
            let results = try viewContext.fetch(fetchRequest)
            bookmarkedNewsURLs = Set(results.compactMap { $0.url })
        } catch {
            print("Error loading bookmarked URLs: \(error)")
        }
    }

    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
