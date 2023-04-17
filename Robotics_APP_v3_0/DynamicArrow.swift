import SwiftUI

struct DynamicArrow: View {
    var pitch: Double
    var roll: Double
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            
            let arrowSize = CGSize(width: 100, height: 150)
            
            let rotationAngle = atan2(roll, -pitch)
            let arrowColor = (pitch > 5 || pitch < -5 || roll > 5 || roll < -5) ? Color.green : Color.gray
            
            Image(systemName: "arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: arrowSize.width, height: arrowSize.height)
                .position(x: centerX, y: centerY)
                .foregroundColor(arrowColor)
                .rotationEffect(Angle(radians: rotationAngle), anchor: UnitPoint(x: 0.5, y: 0.5))
        }
    }
}

struct DynamicArrow_Previews: PreviewProvider {
    static var previews: some View {
        DynamicArrow(pitch: 0, roll: 0)
    }
}
