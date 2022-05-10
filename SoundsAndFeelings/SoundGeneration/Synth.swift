
import Foundation
import AVFoundation

final class Synth {
	
	private static let singleton = Synth()
	static var shared: Synth { return singleton }
	private let audioEngine: AVAudioEngine
	
	/// Container for the 3 waves that compose the sound that can be played.
	private var waves = WaveContainer(waveA: false, waveB: false, waveC: false) {
		didSet {
			if oldValue.waveA.frequency != 0 {
				deltaAHz = Float(waves.waveA.frequency - oldValue.waveA.frequency ) * 100
			}
			else {
				deltaAHz = 0
			}
			
			if oldValue.waveB.frequency != 0 {
				deltaBHz = Float(waves.waveB.frequency - oldValue.waveB.frequency) * 100
			}
			else {
				deltaBHz = 0
			}
			
			if oldValue.waveC.frequency != 0 {
				deltaCHz = Float(waves.waveC.frequency - oldValue.waveC.frequency) * 100
			}
			else {
				deltaCHz = 0
			}
			
		}
	}
	
	// the delta difference to the last computed frequency for each wave.
	private var deltaAHz: Float = 0
	private var deltaBHz: Float = 0
	private var deltaCHz: Float = 0
	
	// frequency in hertz for each wave
	private var aHz: Float {
		Float(waves.waveA.frequency) * 100
	}
	private var bHz: Float {
		Float(waves.waveB.frequency) * 100
	}
	private var cHz: Float {
		Float(waves.waveC.frequency) * 100
	}
	
	/// Volume of the Synth, goes from 0 to 1.
	var volume: Float {
		get {
			audioEngine.mainMixerNode.outputVolume
		}
		set {
			audioEngine.mainMixerNode.outputVolume = newValue
		}
	}
	
	// the time x for each wave (it makes sense in the source node closure)
	private var timeA: Float = 0
	private var timeB: Float = 0
	private var timeC: Float = 0
	
	/// Device sample rate. Sample rate is how many time frames there are in a second. Time frames are the moments at which audio values can be updated in audio buffers. Often the sample value is around 44 000, so the audio buffers are updated at around 44 000 a second.
	let sampleRate: Double
	
	/// The from a time frame to the next (1/sampleRate)
	let deltaTime: Float
	var isPicker = false
	
	/// The property responsible to comunicate with the device's audio buffers and deliver them their specific values for every frame of time.
	lazy var sourceNode = AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
		
		let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
		
		// the difference between the old frequency and the new one, for each wave.
		let aRamp = self.deltaAHz
		let bRamp = self.deltaBHz
		let cRamp = self.deltaCHz
		
		// old frequency for each wave
		let oldA = self.aHz - aRamp
		let oldB = self.bHz - bRamp
		let oldC = self.cHz - cRamp
		
		let aPeriod = 1/oldA
		let bPeriod = 1/oldB
		let cPeriod = 1/oldC

		// for every frame in sample...
		for frame in 0..<Int(frameCount) {
			
			// calculate every sample value for each wave
			let aSample = self.sampleValForSine(oldFrequency: oldA, ramp: aRamp, period: aPeriod, time: self.timeA)
			let bSample = self.sampleValForSine(oldFrequency: oldB, ramp: bRamp, period: bPeriod, time: self.timeB)
			let cSample = self.sampleValForSine(oldFrequency: oldC, ramp: cRamp, period: cPeriod, time: self.timeC)
			
			// progressing time for each wave
			self.timeA += self.deltaTime
			self.timeB += self.deltaTime
			self.timeC += self.deltaTime
			
			// updates the time so it is a value from 0 to the wave's old period.
			// this is to solve sound bugs that happen on sound change in real time
			self.timeA = fmod(self.timeA, aPeriod)
			self.timeB = fmod(self.timeB, bPeriod)
			self.timeC = fmod(self.timeC, cPeriod)
			
			// get the total sample value by adding every sample value for each wave
			let sampleTotalVal = aSample + bSample + cSample
			
			// for every available audio buffer...
			for buffer in ablPointer {
				let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
				
				// give the buffer its sample value for that frame of time.
				buf[frame] = sampleTotalVal
			}
			
		}
		return noErr
	}
	
	/// Calculates the sample value for a sine wave, taking into account the ramp necessary to make the increase or decrease of frequency sound smooth.
	/// - Parameters:
	///   - oldFrequency: the old frequency that is to be updated to a new one
	///   - ramp: difference of frequency between the old frequency and the new one
	///   - period: period for the wave at its old frequency
	///   - time: the time of reference to be used (timeA, timeB, timeC)
	/// - Returns: Sample value
	private func sampleValForSine(oldFrequency: Float, ramp: Float, period: Float, time: Float) -> Float {
		
		let currentTime = fmod(time, period)
		
		// how complete is the transition between the new frequency and the old one
		let percent = currentTime/period
		
		let frequency = oldFrequency + ramp * percent
		
		let angle = 2*Float.pi * currentTime
		let sine = sin(angle * frequency)
		
		return sine
	}
	
	private func sampleValForTriangle(oldFrequency: Float, ramp: Float, period: Float, time: Float) -> Float {
		let currentTime = fmod(time, period)
		let percent = currentTime/period
		let frequency = oldFrequency + ramp * percent
		
		let value = currentTime * frequency
		
		var result: Float = 0.0
		if value < 0.25 {
			result = value * 4
		} else if value < 0.75 {
			result = 2.0 - (value * 4.0)
		} else {
			result = value * 4 - 4.0
		}
		
		return result
		
	}
	
	private init() {
		audioEngine = AVAudioEngine()
		let mainMixer = audioEngine.mainMixerNode
		let outputNode = audioEngine.outputNode
		
		let format = outputNode.inputFormat(forBus: 0)
		
		sampleRate = format.sampleRate
		deltaTime = 1/Float(sampleRate)
		
		let inputFormat = AVAudioFormat(commonFormat: format.commonFormat, sampleRate: sampleRate, channels: 1, interleaved: format.isInterleaved)
		audioEngine.attach(sourceNode)
		audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
		audioEngine.connect(mainMixer, to: outputNode, format: nil)
		
		mainMixer.outputVolume = 0
		
		start()
	}
	
	/// Stops the engine
	func stop() {
		audioEngine.stop()
	}
	
	func resetWaves() {
		waves = WaveContainer(waveA: false, waveB: false, waveC: false)
	}
	
	func resetTime() {
		timeA = 0
		timeB = 0
		timeC = 0
	}
	
	/// Starts the engine (error throw is not handled so it might not work)
	func start() {
		do {
			try audioEngine.start()
		}
		catch { print("Could not start engine: \(error.localizedDescription)") }
	}
	
	/// Updates the value for the synth's wave container
	func setWaves(_ waves: WaveContainer) {
		if isPicker {
			resetTime()
		}
		self.waves = waves
	}
	
}

