import SwiftUI
//import MetalKit

struct ContentView: View {
    let data = Date()
    @State var selection: Int = 0
    
    var body: some View {
//      GeometryReader{ geo in
        TabView {
//          VStack{
            PipeLineView().tabItem {
              Text("PipeLine")
            }
//            TimelineView(.animation) { _ in
//              Color.green
//                .colorEffect(ShaderLibrary.basicColor(.float2(geo.size)))
//                .colorEffect(ShaderLibrary.drawCircle(
//                  .float2(geo.size),
//                  .float2(geo.size.width / 2, geo.size.height * 1 / 2),
//                  .float(80),
//                  .float(data.timeIntervalSinceNow)))
//              
//            
//          }
//            .overlay {
//              
//                Text("Push Me")
//                  .padding(12)
//                  .background(RoundedRectangle(cornerRadius: 5).fill(Color.blue))
//            }
//          }
                
        }
//      }
    }
}

#Preview {
    ContentView()
}
