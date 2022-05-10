import SwiftUI

struct SliderWaveControl: View {
	@Binding var wave: PureWave
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("\(wave.frequency*100) Hz")
				.padding([.top, .leading])
			WaveView(wave: wave)
				.padding(.bottom)
			Slider(value: $wave.frequency, in: 0...10)
				.padding([.trailing, .leading])
			
		}
	}
}
