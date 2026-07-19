import AppKit
import SwiftUI

final class ShortcutStore: ObservableObject {
    static let shared = ShortcutStore()

    @Published var query = ""
    @Published var selectedCategory: ShortcutCategory = .all
    @Published private(set) var favoriteIDs: Set<String>

    private let favoritesKey = "QuickKey.favoriteIDs"

    private init() {
        favoriteIDs = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
    }

    var filteredItems: [ShortcutItem] {
        ShortcutLibrary.items.filter { item in
            let categoryMatches: Bool
            switch selectedCategory {
            case .all: categoryMatches = true
            case .favorites: categoryMatches = favoriteIDs.contains(item.id)
            default: categoryMatches = item.category == selectedCategory
            }
            return categoryMatches && item.matches(query.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    var favorites: [ShortcutItem] {
        ShortcutLibrary.items.filter { favoriteIDs.contains($0.id) }
    }

    func toggleFavorite(_ item: ShortcutItem) {
        if favoriteIDs.contains(item.id) {
            favoriteIDs.remove(item.id)
        } else {
            favoriteIDs.insert(item.id)
        }
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }

    func isFavorite(_ item: ShortcutItem) -> Bool {
        favoriteIDs.contains(item.id)
    }

    func copy(_ item: ShortcutItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.keyText, forType: .string)
    }
}
