//
//  Library.swift
//  IMusic
//
//  Created by Sergey Lobanov on 05.11.2021.
//

import SwiftUI

struct Library: View {
    var body: some View {
        NavigationView {
            // что бы настроить кнопки надо исползовать GeometryReader
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button {
                            print("123")
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .frame(width: abs(geometry.size.width / 2 - 10), height: 50)
                        .tint(Color(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333))
                        .background(Color(red: 0.9531342387, green: 0.9490900636, blue: 0.9562709928))
                        .cornerRadius(10)

                        Button {
                            print("456")
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        .frame(width: abs(geometry.size.width / 2 - 10), height: 50)
                        .tint(Color(red: 0.9921568627, green: 0.1764705882, blue: 0.3333333333))
                        .background(Color(red: 0.9531342387, green: 0.9490900636, blue: 0.9562709928))
                        .cornerRadius(10)
                    }

                }
                .padding()
                .frame(height: 65)
                
                Divider()
                    .padding(.leading)
                    .padding(.trailing)

                List {
                    LibraryCell()
                    Text("fisrt")
                    Text("second")
                }
            }
                .navigationTitle("Library")
        }
    }
}

struct LibraryCell: View {
    var body: some View {
        HStack {
            Image("Image")
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(2)
            VStack {
                Text("Track name")
                Text("Artist name")
            }
        }

    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
