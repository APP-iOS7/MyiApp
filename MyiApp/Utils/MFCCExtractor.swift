//
//  MFCCExtractor.swift
//  MyiApp
//
//  Created by 조영민 on 5/13/25.
//

import Accelerate
import Foundation

struct MFCCExtractor {
    let sampleRate: Float = 22050
    let frameLength: Int = 2048
    let hopLength: Int = 512
    let numMelBands: Int = 40
    let numCoefficients: Int = 13

    func extract(from signal: [Float]) -> [[Float]] {
        guard signal.count >= frameLength else { return [] }

        let numFrames = (signal.count - frameLength) / hopLength + 1
        var mfccs: [[Float]] = []

        // 1. Hann Window
        var window = [Float](repeating: 0.0, count: frameLength)
        vDSP_hann_window(&window, vDSP_Length(frameLength), Int32(vDSP_HANN_NORM))

        // 2. DCT setup
        guard let dctSetup = vDSP_DCT_CreateSetup(nil, vDSP_Length(numMelBands), .II) else {
            return []
        }

        for frameIndex in 0..<numFrames {
            let start = frameIndex * hopLength
            let end = start + frameLength
            let frame = Array(signal[start..<end])

            // 3. Apply window
            var windowed = [Float](repeating: 0.0, count: frameLength)
            vDSP_vmul(frame, 1, window, 1, &windowed, 1, vDSP_Length(frameLength))

            // 4. FFT
            var realp = [Float](repeating: 0.0, count: frameLength / 2)
            var imagp = [Float](repeating: 0.0, count: frameLength / 2)
            realp.withUnsafeMutableBufferPointer { realBuf in
                imagp.withUnsafeMutableBufferPointer { imagBuf in
                    windowed.withUnsafeBufferPointer { inputBuf in
                        var complexBuffer = DSPSplitComplex(realp: realBuf.baseAddress!, imagp: imagBuf.baseAddress!)
                        inputBuf.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: frameLength / 2) { complexPtr in
                            let log2n = vDSP_Length(log2(Float(frameLength)))
                            if let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) {
                                vDSP_ctoz(complexPtr, 2, &complexBuffer, 1, vDSP_Length(frameLength / 2))
                                vDSP_fft_zrip(fftSetup, &complexBuffer, 1, log2n, FFTDirection(FFT_FORWARD))
                                vDSP_destroy_fftsetup(fftSetup)
                            }
                        }
                    }
                }
            }

            // 5. Power spectrum
            var magnitudes = [Float](repeating: 0.0, count: frameLength / 2)
            
            // Fix: 여기서 realp와 imagp 배열에 안전하게 접근
            realp.withUnsafeMutableBufferPointer { realBuf in
                imagp.withUnsafeMutableBufferPointer { imagBuf in
                    var splitComplex = DSPSplitComplex(realp: realBuf.baseAddress!, imagp: imagBuf.baseAddress!)
                    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(frameLength / 2))
                }
            }

            // 6. Mel filterbank (simplified - real Mel filters needed for production)
            let melEnergies = Array(magnitudes.prefix(numMelBands))

            // 7. Log compression
            let epsilon: Float = 1e-6
            var logMel = melEnergies.map { log($0 + epsilon) }

            // 8. DCT → MFCC
            var mfcc = [Float](repeating: 0.0, count: numCoefficients)
            vDSP_DCT_Execute(dctSetup, &logMel, &mfcc)

            mfccs.append(mfcc)
        }
        
        return mfccs
    }
}
