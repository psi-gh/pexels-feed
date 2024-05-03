import SwiftUI

struct DetailView: View {
    let photo: Photo
    @GestureState private var zoom = 1.0
    
    var body: some View {
        ScrollView {
            AsyncImage(url: URL(string: photo.source.original)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(zoom)
                    .gesture(
                        MagnifyGesture()
                            .updating($zoom) { value, gestureState, transaction in
                                gestureState = value.magnification
                            }
                    )
            } placeholder: {
                ProgressView()
            }
        }
        .navigationTitle(photo.photographer)
        .navigationBarTitleDisplayMode(.inline)
    }
}
