import SwiftUI

struct LidarControlButton: View {
    var title: String
    var action: () -> Void
    @Binding var active: Bool

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(active ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct LidarControlButton_Previews: PreviewProvider {
    @State static var active = false

    static var previews: some View {
        LidarControlButton(title: "Following", action: {}, active: $active)
    }
}
