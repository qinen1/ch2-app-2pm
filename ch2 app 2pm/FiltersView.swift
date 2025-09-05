import SwiftUI

struct FiltersView: View {
    enum Filter: String {
        case none, greyscale, invertedColors
    }
    var finalImage: Image?
    @State private var selected: Filter = .none
    var body: some View {
        NavigationStack {
            VStack {
                if let image = finalImage {
                    switch selected {
                    case .none:
                        image
                            .resizable()
                            .scaledToFit()
                    case .greyscale:
                        image
                            .resizable()
                            .scaledToFit()
                            .grayscale(1.0)
                    case .invertedColors:
                        image
                            .resizable()
                            .scaledToFit()
                            .colorInvert()
                    }
                }
                Spacer()
                Button {
                    selected = .greyscale
                    
                } label: {
                    Text("Greyscale Filter")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                
                Button {
                    selected = .invertedColors
                } label: {
                    Text("Inverted Colors Filter")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                Button {
                    selected = .none
                } label: {
                    Text("No Filter")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                NavigationLink(destination: FinalProductView(finalImage: finalImage, filter: selected)) {
                    Text("Next")
                }
                .navigationTitle("Filters")
                
            }
        }
    }
}
#Preview {
    FiltersView(finalImage: Image("james"))
}

