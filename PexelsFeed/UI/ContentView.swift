// ContentView.swift
// Copyright (c) 2024 Pavel Ivanov
// Created by Pavel Ivanov on 01.05.2024.

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel

    var body: some View {
        NavigationView {
            Group {
//                if viewModel.isLoading {
//                    loader
//                } else {
//                AsyncImage(url: URL(string: "https://images.pexels.com/photos/22915660/pexels-photo-22915660.jpeg?auto=compress&cs=tinysrgb&h=350"))
                    grid
//                }
            }
            .navigationTitle("Pexels Feed")
            .onAppear {
                viewModel.loadPhotos()
            }
        }
    }
    
    @ViewBuilder
    var grid: some View {
        let columns = [
            GridItem(.adaptive(minimum: 120, maximum: 190), spacing: 20),
        ]
        
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.photos, id: \.id) { photo in
                    VStack {
                        Color.clear.overlay(
                            AsyncImage(url: URL(string: photo.source.large)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                        )
                        .aspectRatio(9/16, contentMode: .fill)
                        .clipped()
                        
                        Text(photo.photographer)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(8)
    }
    
    @ViewBuilder
    var grid2: some View {
        let columns = [
            GridItem(.adaptive(minimum: 120, maximum: 190), spacing: 20),
//            GridItem(.flexible(minimum: 50, maximum: 190), spacing: 20)
        ]
        
        GeometryReader { geometry in
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.photos, id: \.id) { photo in
                        let source = photo.source.medium
//                        cell2(photo)
                        VStack {
//                            Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: source)!))!)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(height: 150)
//                            .clipped()
//                            .border(Color.green, width: 2)
                            
//                            AsyncImage(url: URL(string: photo.source.medium)) { image in
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                            } placeholder: {
//                                ProgressView()
//                            }
                            
                            Image("pexels-photo3")
                                .resizable()
//                                .scaledToFit()
                                .aspectRatio(contentMode: .fill)
//                                .frame(width: (geometry.size.width - 10 - 8 - 8)/2, height: 150)
                                .frame(height: 150)
                                .clipped()
                                .border(Color.green, width: 2)
                            
                            Text(photo.photographer)
                                .font(.caption)
                        }
//                            .frame(width: 183, height: 150)

//                            .frame(minHeight: 100)
//                            .frame(width: (geometry.size.width - 10 - 8 - 8)/2)
                        //                    VStack {
                        //                        AsyncImage(url: URL(string: source)) { image in
                        //                            image
                        //                                .resizable()
                        //                                .aspectRatio(contentMode: .fill)
                        //                        } placeholder: {
                        //                            ProgressView()
                        //                        }
                        //                        .frame(width: 100, height: 100)
                        //                        .clipped()
                        //                        .border(Color.green, width: 2)
                        //
                        //                        Text(photo.photographer)
                        //                            .font(.caption)
                        //                    }
                    }
                }
            }
            .padding(8)
        }
        //                    AsyncImage(url: URL(string: source)) { image in
        //                        image
        //                            .resizable()
        //                            .aspectRatio(contentMode: .fill)
        //                    } placeholder: {
        //                        ProgressView()
        //                    }
        //                    .frame(height: 200) // Set a fixed height for each image
        //                    .border(Color.red, width: 1)
        //                    Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: source)!))!)

    }
    
    @ViewBuilder
    var list: some View {
        List {
            ForEach(viewModel.photos, id: \.id) { photo in
                let source = photo.source.medium
                AsyncImage(url: URL(string: source)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .clipped()
                .border(Color.green, width: 2)
            }
        }
    }
    
    @ViewBuilder
    func cell2(_ photo: Photo) -> some View {
        VStack {
            AsyncImage(url: URL(string: photo.source.medium)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .clipped()
            .border(Color.green, width: 2)
            
            Text(photo.photographer)
                .font(.caption)
        }
    }
    
    @ViewBuilder
    func cell(_ photo: Photo) -> some View {
        VStack {
            AsyncImage(url: URL(string: photo.source.medium)) { phase in
                
                if let image = phase.image {
                    image
                        .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200, alignment: .topLeading)
                                .border(.blue)
                                .clipped()
                } else {
                    Color
                        .blue
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)

                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(height: 200, alignment: .topLeading)
            .border(.blue)
            .clipped()
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .shadow(radius: 5)

            
            Text(photo.photographer)
                .font(.caption)
//            Color.random()
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .shadow(radius: 5)
        }
//        .clipped()
//        .padding(.horizontal)
        .border(Color.red, width: 2.0)
    }

    @ViewBuilder
    var loader: some View {
        ProgressView()
    }
}

// #Preview {
//    ContentView()
// }

extension Color {
    static func random() -> Color {
        // Randomly generate RGB values
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        
        // Return a new Color
        return Color(red: red, green: green, blue: blue)
    }
}
