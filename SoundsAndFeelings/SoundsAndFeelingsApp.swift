import SwiftUI

@main
struct MyApp: App {
	
	@State var sound = Sound()
	
	init() {
		Synth.shared.start()
	}
	
	var body: some Scene {
		WindowGroup {
			
			GeometryReader { geometry in
				VStack(spacing: 0) {
					
					Spacer(minLength: geometry.size.height*0.035)
					
					ResultantWave(sound: $sound)
					
					SliderInterface(sound: $sound)
				}
				.preferredColorScheme(.dark)
			}
			
		}
	}
}

struct ResultantWave: View {
	
	@Binding var sound: Sound
	
	var body: some View {
		VStack {
			
			ScrollView(.horizontal) {
				let waveSum = WaveSum(container: sound.waves)
				WaveView(wave: waveSum)
					.frame(width: 4000)
					.padding(.top)
					.onChange(of: sound.waves) { newValue in
						Synth.shared.setWaves(newValue)
					}
			}
			
			PlayButton(sound: $sound)
				.padding(.top)
			
		}
	}
}


//struct Pages: View {
//
//	@Binding var sound: Sound
//
//	var body: some View {
//		TabView {
//			Page1(sound: $sound)
//				.onAppear {
//					Synth.shared.isPicker = false
//				}
//				.onDisappear {
//					Synth.shared.isPicker = true
//				}
//			Page2(sound: $sound)
//
//			Page3(sound: $sound)
//				.onAppear {
//					Synth.shared.isPicker = true
//				}
//				.onDisappear {
//					Synth.shared.isPicker = true
//				}
//			Page4(sound: $sound)
//				.onAppear {
//					Synth.shared.isPicker = true
//				}
//		}
//		.tabViewStyle(.page(indexDisplayMode: .always))
//	}
//}

