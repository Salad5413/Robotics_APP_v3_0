import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
    @Published var currentGesture: String = "STOP"
    @Published var connectionStatus: String = "Disconnected"
    @Published var isConnected: Bool = false {
        didSet {
            if isConnected {
                setupWebSocket()
            } else {
                sendWebSocketMessage(degree_lr: 0, degree_fb: 0)
                disconnect()
            }
        }
    }
    
    @Published var pitch: Double = 0
    @Published var roll: Double = 0

    // Add new published properties for following, avoiding, and guard
    @Published var following: Bool = false
    @Published var avoiding: Bool = false
    @Published var guardMode: Bool = false

    private var webSocketTask: URLSessionWebSocketTask?
    
    init() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
                guard let motion = motion else { return }
                
                self.pitch = motion.attitude.pitch * 180 / .pi
                self.roll = motion.attitude.roll * 180 / .pi
                
                var gesture: String = ""
                var degree_lr: Int = 0
                var degree_fb: Int = 0
                
                if self.pitch > 5 {
                    gesture += "Backward"
                } else if self.pitch < -5 {
                    gesture += "Forward"
                }
                
                if self.roll > 5 {
                    gesture += gesture.isEmpty ? "Right" : " and Right"
                } else if self.roll < -5 {
                    gesture += gesture.isEmpty ? "Left" : " and Left"
                }
                
                degree_lr = Int(self.roll)
                degree_fb = Int(self.pitch)
                
                self.currentGesture = gesture.isEmpty ? "STOP" : "\(gesture)\nx-axis: (\(degree_fb)°)\ny-axis: (\(degree_lr)°)"
                
                // Send data to the Python server
                if self.isConnected {
                    self.sendWebSocketMessage(degree_lr: degree_lr, degree_fb: degree_fb)
                }
            }
        }
    }
    
    private var urlString: String?
    func connect(urlString: String) {
        self.urlString = urlString
        disconnect()
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message, text == "Connected" {
                    DispatchQueue.main.async {
                        self?.connectionStatus = "Connected"
                    }
                }
            case .failure(let error):
                print("WebSocket connection error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionStatus = "Connection failed"
                    self?.isConnected = false
                }
            }
            
            if self?.isConnected == true {
                self?.setupWebSocket()
            }
        })
    }
    
    func sendWebSocketMessage(degree_lr: Int, degree_fb: Int) {
        let message = "\(degree_lr),\(degree_fb)"
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Error sending WebSocket message: \(error)")
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus = "Disconnected"
    }

    // Add new methods for toggling following, avoiding, and guard
    func toggleFollowing() {
        if !following {
            sendCommand(command: "start_following")
            following = true
            avoiding = false
            guardMode = false
        } else {
            sendCommand(command: "stop_following")
            following = false
        }
    }
    
    func toggleAvoiding() {
        if !avoiding {
            sendCommand(command: "start_avoiding")
            following = false
            avoiding = true
            guardMode = false
        } else {
            sendCommand(command: "stop_avoiding")
            avoiding = false
        }
    }

    func toggleGuard() {
        if !guardMode {
            sendCommand(command: "start_guard")
            following = false
            avoiding = false
            guardMode = true
        } else {
            sendCommand(command: "stop_guard")
            guardMode = false
        }
    }

    // Helper function to send a command to the Python server
    func sendCommand(command: String) {
        webSocketTask?.send(.string(command)) { error in
            if let error = error {
                print("Error sending WebSocket command: \(error)")
            }
        }
    }
}
