
import SwiftUI

protocol Wave {
	var maxAmplitude: Double {get set}
		
	///Value Y of the function for an angle X
	func intensity(forAngle: Double) -> Double
	
}


struct PureWave: Wave, Equatable {
		
	var maxAmplitude: Double
	var frequency: Double
	
	init(frequency: Double = 4.4, maxAmplitude: Double = 25) {
		self.frequency = frequency
		self.maxAmplitude = maxAmplitude
	}
	
	func intensity(forAngle angle: Double) -> Double {
		let sine = sin(angle*frequency)
		let y = sine * maxAmplitude
		
		return y
	}
	
}

struct WaveSum: Wave {
	
	var maxAmplitude: Double {
		get {
			a.maxAmplitude + b.maxAmplitude + c.maxAmplitude
		}
		set{}
	}
	
	let a: PureWave
	let b: PureWave
	let c: PureWave

	
	init(a: PureWave, b: PureWave, c: PureWave) {
		self.a = a
		self.b = b
		self.c = c
	}
	
	init(container: WaveContainer) {
		a = container.waveA
		b = container.waveB
		c = container.waveC
	}
	
	func intensity(forAngle angle: Double) -> Double {
		return a.intensity(forAngle: angle) + b.intensity(forAngle: angle) + c.intensity(forAngle: angle)
	}
	
	
}



