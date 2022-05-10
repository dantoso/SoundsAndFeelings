import Foundation

struct Sound: Equatable {
	var isPlaying: Bool = false
	var waves: WaveContainer = WaveContainer()
	
	init() {
		self.isPlaying = false
		self.waves = WaveContainer()
	}
	
	init(waveA: Bool, waveB: Bool, waveC: Bool) {
		self.isPlaying = false
		self.waves = WaveContainer(waveA: waveA, waveB: waveB, waveC: waveC)
	}
}

struct WaveContainer: Equatable {
	var waveA: PureWave
	var waveB: PureWave
	var waveC: PureWave
	
	init() {
		waveA = PureWave()
		waveB = PureWave()
		waveC = PureWave()
	}
	
	init(waveA: Bool, waveB: Bool, waveC: Bool) {
		self.waveA = waveA ? PureWave() : PureWave(frequency: 0, maxAmplitude: 0)
		self.waveB = waveB ? PureWave() : PureWave(frequency: 0, maxAmplitude: 0)
		self.waveC = waveC ? PureWave() : PureWave(frequency: 0, maxAmplitude: 0)
	}
	
}
