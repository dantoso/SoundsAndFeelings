import SwiftUI

struct PlayButton: View {
	
	@Binding var sound: Sound
	
	var body: some View {
		
		Button(sound.isPlaying ? "Stop" : "Play") {
			sound.isPlaying.toggle()
			if sound.isPlaying {
//				Synth.shared.start()
				Synth.shared.setWaves(sound.waves)
				Synth.shared.volume = 0.2
			}
			else {
				Synth.shared.volume = 0
//				Synth.shared.stop()
			}
		}
		.buttonStyle(.bordered)
		
	}
}
