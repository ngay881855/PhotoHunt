//
//  ContentView.swift
//  PhotoHunt-SwiftUI-Async
//
//  Created by David Vong on 1/15/25.
//

import SwiftUI

private enum SelectedTab {
    case search
    case saved
}

struct HomeView: View {
    @State private var selectedTab: SelectedTab = .search
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                SearchView()
                    .tabItem {
                        HStack {
                            Image(systemName: "magnifyingglass") // SF Symbol for "loop up"
                            Text("Search")
                        }
                    }.tag(SelectedTab.search)
                SavedPhotoView()
                    .tabItem {
                        HStack {
                            Image(systemName: "square.and.arrow.down.on.square")
                            Text("Saved photos")
                        }
                    }.tag(SelectedTab.saved)
            }
        }
    }
}

#Preview {
    HomeView()
}

struct SearchView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("This will have a list of photos")
            }
        }
    }
}

struct SavedPhotoView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("This will have a list of saved photos store in SwiftData")
            }
        }
    }
}

struct TabButton: View {
    let image: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: image)
                    .font(.title)
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(title)
                    .font(.footnote)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
