
import SwiftUI

struct WaveView: View {
	
	// custom shape that does the drawing
	struct WavePath: Shape {
		let wave: Wave
		
		func path(in rect: CGRect) -> Path {
			var path = Path()
			
			let waveLength: Double = 200
			let height = Double(rect.height)
			let width = Double(rect.width)

			let origin = CGPoint(x: 0, y: height*0.5)
			
			path.move(to: origin)
			for x in stride(from: 0, through: width, by: 0.5) {
				let angle = x/waveLength * 2*Double.pi
				let y = wave.intensity(forAngle: angle) + height*0.5
				
				path.addLine(to: CGPoint(x: x, y: y))
			}
			
			return path
		}
	}
	
	let wave: Wave
	
	var body: some View {
		WavePath(wave: wave)
			.stroke(lineWidth: 2)
			.frame(height: wave.maxAmplitude*2)
	}

}
