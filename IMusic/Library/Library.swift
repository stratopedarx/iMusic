//
//  Library.swift
//  IMusic
//
//  Created by Sergey Lobanov on 05.11.2021.
//

import SwiftUI

// MARK: - Library

struct Library: View {
    static let buttonColor = Color(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333)
    static let backgroundColor = Color(red: 0.9531342387, green: 0.9490900636, blue: 0.9562709928)

    // изменение интерфейса завязано на изменении свойств
    // мы хотим изменить свойство tracks и сразу же хотим, что бы интерфейс обновился
    // по умолчанию у свойства нет такого свойства, поэтому надо использовать State
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showingAlert = false
    @State private var track: SearchViewModel.Cell!  // -- здесь будет храниться инфмормация по ячейке

    var tabBarDelegate: MainTabBarControllerDelegate?

    var body: some View {
        NavigationView {
            // что бы настроить кнопки надо исползовать GeometryReader
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button {
                            track = tracks[0]
                            tabBarDelegate?.maximizedTrackDetailController(viewModel: track)
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .frame(width: abs(geometry.size.width / 2 - 10), height: 50)
                        .tint(Library.buttonColor)
                        .background(Library.backgroundColor)
                        .cornerRadius(10)

                        Button {
                            // обновляем поле tracks
                            tracks = UserDefaults.standard.savedTracks()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        .frame(width: abs(geometry.size.width / 2 - 10), height: 50)
                        .tint(Library.buttonColor)
                        .background(Library.backgroundColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .frame(height: 65)
                
                Divider()
                    .padding(.leading)
                    .padding(.trailing)
                
                showListOfTracks()

            }
            // будем менять значение $showingAlert при полгом нажатии на ячейку.
            .actionSheet(isPresented: $showingAlert, content: {
                ActionSheet(
                    title: Text("Are you sure you wnat to delete this track?"),
                    buttons: [.destructive(
                        Text("Delete"),
                        action: {
                            // тут у нас нет доступа к ячейке
                            print("Deleting: \(track.trackName)")
                            self.delete(track: track)
                        }),
                              .cancel()]
                )
            })
            
            .navigationTitle("Library")
        }
    }

    // MARK - delete button

    private func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        // удаление и добавление на симуляторе работает не очень. не реальном устройство всё ок.
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks,
                                                             requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    private func delete(track: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let index = index else { return }
        tracks.remove(at: index)
        // удаление и добавление на симуляторе работает не очень. не реальном устройство всё ок.
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks,
                                                             requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    // MARK: - Show list of tracks
    
    private func showListOfTracks() -> some View {
        // мы хотим добавить возможность удаление свайпом <--
        // List не имеет такой возможности, а вот ForEash имеет метод onDelete
        List {
            ForEach(tracks) { track in
                LibraryCell(cell: track)
                
                // добавляем gesture долгое нажатие. меняем флаг showingAlert
                    .gesture(
                        LongPressGesture()
                            .onEnded { _ in
                                self.track = track
                                showingAlert = true
                            }
                    )
                // не очень очевидно добавляем еще один жест
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                
                                // при открытии трека в окне Library нам нужно менять делегата, что бы корректно
                                // переключение треков отрабатывало
                                
                                // добираемся до основного экрана. Раньше это выглядело проще
                                // let keyWindow = UIApplication.shared.keyWindow
                                let keyWindow = UIApplication.shared.connectedScenes.filter {
                                    $0.activationState == .foregroundActive
                                }
                                    .map { $0 as? UIWindowScene }
                                    .compactMap { $0 }
                                    .first?.windows.filter { $0.isKeyWindow }
                                    .first
                                // теперь получаем наш tabBar
                                let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                                // и меняем делегата
                                tabBarVC?.trackDetailView.delegate = self
                                
                                
                                
                                self.track = track
                                tabBarDelegate?.maximizedTrackDetailController(viewModel: track)
                            }
                    )
            }
            .onDelete(perform: delete)
        }
    }
}

// MARK: - TrackMovingDelegate

extension Library: TrackMovingDelegate {
    
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let index = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if isForwardTrack {
            let nextIndex = index + 1
            if nextIndex == tracks.count {
                nextTrack = tracks[0]
            } else {
                nextTrack = tracks[nextIndex]
            }
        } else {
            let previousIndex = index - 1
            if previousIndex == -1 {
                nextTrack = tracks[tracks.count - 1]
            } else {
                nextTrack = tracks[previousIndex]
            }
        }
        
        self.track = nextTrack
        return nextTrack
    }
    
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        getTrack(isForwardTrack: false)
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        getTrack(isForwardTrack: true)
    }
}

// MARK: - Library_Previews

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
