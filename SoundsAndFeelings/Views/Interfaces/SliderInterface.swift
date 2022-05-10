import SwiftUI

struct SliderInterface: View {

	@Binding var sound: Sound
	
	var body: some View {
		VStack {
			
			SliderWaveControl(wave: $sound.waves.waveA)
				.onChange(of: sound.waves) { newValue in
					Synth.shared.setWaves(newValue)
				}
			SliderWaveControl(wave: $sound.waves.waveB)
				.onChange(of: sound.waves) { newValue in
					Synth.shared.setWaves(newValue)
				}
			SliderWaveControl(wave: $sound.waves.waveC)
				.onChange(of: sound.waves) { newValue in
					Synth.shared.setWaves(newValue)
				}
		}
		.frame(alignment: .center)
	}
}
