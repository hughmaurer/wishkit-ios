//
//  WishlistContainer.swift
//  wishkit-ios
//
//  Created by Martin Lasek on 3/11/23.
//  Copyright © 2023 Martin Lasek. All rights reserved.
//

#if os(macOS) || os(visionOS)
import SwiftUI
import WishKitShared

enum LocalWishState: Hashable, Identifiable {
    case all
    case approved
    case library(WishState)

    var id: String { description }

    var description: String {
        switch self {
        case .all:
            return "all".localized()
        case .approved:
            return "approved".localized()
        case .library(let wishState):
            return wishState.description
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

struct WishlistContainer: View {

    @Environment(\.colorScheme)
    private var colorScheme

    @State
    private var selectedWishState: LocalWishState = .approved

    @State
    private var isRefreshing = false
    
    @State
    private var showingCreateSheet = false

    @ObservedObject
    private var wishModel: WishModel

    init(wishModel: WishModel) {
        self.wishModel = wishModel
        self.wishModel.fetchList()
    }

    func refreshList() {
        isRefreshing = true
        wishModel.fetchList {
            DispatchQueue.main.async {
                isRefreshing = false
            }
        }
    }

    var body: some View {
        VStack {
            switch WishKit.config.buttons.segmentedControl.display {
            case .show:
                segmentedControlView
            case .hide:
                noSegmentedControlView
            }

            WishlistView(wishModel: wishModel, selectedWishState: $selectedWishState)
                .background(systemBackgroundColor)
            
        }.background(systemBackgroundColor)
    }

    private var feedbackStateSelection: [LocalWishState] {
        return [
            .approved,
            .library(.completed),
        ]
    }

    private func getCountFor(state: LocalWishState) -> Int {
        switch state {
        case .all:
            return wishModel.all.count
        case .approved:
            return wishModel.approved.count
        case .library(let wishState):
            switch wishState {
            case .pending:
                return wishModel.pendingList.count
            case .inReview, .approved:
                return wishModel.inReviewList.count
            case .planned:
                return wishModel.plannedList.count
            case .inProgress:
                return wishModel.inProgressList.count
            case .completed, .implemented:
                return wishModel.completedList.count
            case .rejected:
                return 0
            }
        }
    }

    var segmentedControlView: some View {
        HStack {

            if WishKit.config.buttons.segmentedControl.display == .show {
                Picker("", selection: $selectedWishState) {
                    ForEach(feedbackStateSelection, id: \.self) { state in
                        Text("\(state.description) (\(getCountFor(state: state)))")
                            .tag(state)
                    }
                }.frame(maxWidth: 150)
            }

            Spacer()

            Button(action: refreshList) {
                if isRefreshing {
                    Text(WishKit.config.localization.refreshing)
                } else {
                    Text(WishKit.config.localization.refresh)
                }
            }

            if WishKit.config.buttons.addButton.location == .navigationBar {
                Button(action: { self.showingCreateSheet.toggle() }) {
                    Text(WishKit.config.localization.addButtonInNavigationBar)
                }
                .padding(.leading, 15)
                .sheet(isPresented: $showingCreateSheet) {
                    CreateWishView(
                        createActionCompletion: { wishModel.fetchList() },
                        closeAction: { self.showingCreateSheet = false }
                    )
                    .frame(minWidth: 500, idealWidth: 500, minHeight: 400, maxHeight: 600)
                    .background(systemBackgroundColor)
                }
            }
        }.padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 20))
    }

    var noSegmentedControlView: some View {
        HStack {
            Button(action: refreshList) {
                if isRefreshing {
                    Text(WishKit.config.localization.refreshing)
                } else {
                    Text(WishKit.config.localization.refresh)
                }
            }.padding(.trailing, WishKit.config.buttons.addButton.location == .floating ? 15 : 0)

            if WishKit.config.buttons.addButton.location == .navigationBar {
                Button(action: { self.showingCreateSheet.toggle() }) {
                    Text(WishKit.config.localization.addButtonInNavigationBar)
                }
                .padding(.leading, 15)
                .sheet(isPresented: $showingCreateSheet) {
                    CreateWishView(
                        createActionCompletion: { wishModel.fetchList() },
                        closeAction: { self.showingCreateSheet = false }
                    )
                    .frame(minWidth: 500, idealWidth: 500, minHeight: 400, maxHeight: 600)
                    .background(systemBackgroundColor)
                }
            }
        }.padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 15))
    }

    var systemBackgroundColor: Color {
        switch colorScheme {
        case .light:
            if let color = WishKit.theme.tertiaryColor {
                return color.light
            }

            return PrivateTheme.systemBackgroundColor.light
        case .dark:
            if let color = WishKit.theme.tertiaryColor {
                return color.dark
            }

            return PrivateTheme.systemBackgroundColor.dark
        @unknown default:
            if let color = WishKit.theme.tertiaryColor {
                return color.light
            }

            return PrivateTheme.systemBackgroundColor.light
        }
    }
}
#endif
