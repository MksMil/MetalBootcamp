import SwiftUI

struct PipeLineView: View {
    var body: some View {
        VStack{
            MetalView()
                .border(.black, width: 2)
            Text("Hello, Metal!")
        }
        .padding()
    }
}

#Preview {
    PipeLineView()
  
}
