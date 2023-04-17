import SwiftUI

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var urlString = "ws://192.168.0.110:8080"
    
    // Add this state to track the active view
    @State private var activeView: Int = 0
    
    var body: some View {
        TabView(selection: $activeView) {
            VStack {
                Text("Controller")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
                    DynamicArrow(pitch: motionManager.pitch, roll: motionManager.roll)
                        .frame(width: 45, height: 450)
                    Spacer()
                }
                .padding(.bottom)
                
                TextField("Enter WebSocket URL", text: $urlString, onCommit: {
                    motionManager.connect(urlString: urlString)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Text(motionManager.currentGesture)
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Toggle(isOn: $motionManager.isConnected) {
                        Text(motionManager.connectionStatus)
                            .font(.title2)
                    }
                    .padding()
                    Spacer()
                }
            }
            .tabItem {
                Text("Controller")
                
                
            }
            .tag(0)
            
            VStack {
                Text("Lidar")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                VStack {
                    LidarControlButton(title: "Following", action: { motionManager.toggleFollowing() }, active: $motionManager.following)
                    LidarControlButton(title: "Avoiding", action: { motionManager.toggleAvoiding() }, active: $motionManager.avoiding)
                    LidarControlButton(title: "Guard", action: { motionManager.toggleGuard() }, active: $motionManager.guardMode)
                }
                .padding()
                
                Spacer()
            }
            .tabItem {
                Text("Lidar")
            }
            .tag(1)
        }
        .onAppear {
            motionManager.connect(urlString: urlString)
        }
        .onDisappear {
            motionManager.disconnect()
        }
    }
}
