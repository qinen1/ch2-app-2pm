import SwiftUI

struct FiltersView: View {
    var finalImage: Image?
    
    var body: some View {
        NavigationStack {
            VStack {
                finalImage?
                    .resizable()
                    .scaledToFit()
                
                if let finalImage {
                    ShareLink(item: finalImage, preview: SharePreview("Filters", image: finalImage))
                        .padding()
                }
                
                Spacer()
                
                // Greyscale option
                NavigationLink(destination: GreyscaleView(finalImage: finalImage)) {
                    Text("Greyscale Filter")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                
                // Inverted color option
                NavigationLink(destination: InvertedView(finalImage: finalImage)) {
                    Text("Inverted Colors Filter")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("Filters")
            
            (Text("Hello, World!"))
        }
    }
}

#Preview {
    FiltersView(finalImage: Image("james"))
}
