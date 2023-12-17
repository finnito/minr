//
//  AppIcon.swift
//  mInr
//
//  Created by Finn LeSueur on 5/12/23.
//

import Foundation
import SwiftUI
import os

enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case blue = "AppIcon_blue"
    case peach = "AppIcon_peach"
    case purpleBlue = "AppIcon_purple-blue"
    case sixColours = "AppIcon_six-colours"
    case yellowPeach = "AppIcon_yellow-peach"
    

    var id: String { rawValue }
    var iconName: String? {
        switch self {
        case .primary:
            return nil // Uses default icon
        default:
            return rawValue
        }
    }

    var preview: UIImage {
        UIImage(named: rawValue) ?? UIImage()
    }
}

final class ChangeAppIconViewModel: ObservableObject {
    @Published private(set) var selectedAppIcon: AppIcon

    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    func updateAppIcon(to icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        Task { @MainActor in
            
            // No need to update since we're already using this icon.
            guard UIApplication.shared.alternateIconName != icon.iconName else {
                return
            }
            
            Logger().info("AppIcon: will attempt to change from \(previousAppIcon.rawValue) to \(icon.iconName ?? "No name provided.").")

            do {
                try await UIApplication.shared.setAlternateIconName(icon.iconName)
            } catch {
                // We're only logging the error here and not actively handling the app icon failure
                // since it's very unlikely to fail.
                Logger().info("Updating icon to \(String(describing: icon.iconName)) failed.")

                // Restore previous app icon
                selectedAppIcon = previousAppIcon
            }
        }
    }
}

struct ChangeAppIconView: View {
    @StateObject var viewModel = ChangeAppIconViewModel()

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]) {
            ForEach(AppIcon.allCases) { appIcon in
                    Image(uiImage: appIcon.preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .shadow(
                            color: Color.accentColor.opacity(appIcon.iconName == UIApplication.shared.alternateIconName ? 1 : 0),
                            radius: 5,
                            x: 0, y: 0)
                .onTapGesture {
                    withAnimation {
                        viewModel.updateAppIcon(to: appIcon)
                    }
                }
            }
        }
    }
}
