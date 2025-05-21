//
//  MFCCExtractor.swift
//  MyiApp
//
//  Created by 조영민 on 5/13/25.
//

import Accelerate
import Foundation

// MFCC를 추출하는 구조체
struct MFCCExtractor {
    let sampleRate: Float = 22050
    let frameLength: Int = 2048 // 한 프레임당의 길이
    let hopLength: Int = 512 // 프레임 간격
    let numMelBands: Int = 40 // Mel 필터 수
    let numCoefficients: Int = 13 // 최종 추출할 MFCC 계수 수

    // 음성 신호로부터 MFCC 특징 벡터 배열을 추출
    func extract(from signal: [Float]) -> [[Float]] {
        guard signal.count >= frameLength else { return [] }

        // Pre-emphasis 필터 적용: y[n] = x[n] - alpha * x[n-1]
        let alpha: Float = 0.97
        var emphasizedSignal = signal
        for i in stride(from: emphasizedSignal.count - 1, to: 0, by: -1) {
            emphasizedSignal[i] -= alpha * emphasizedSignal[i - 1]
        }

        let numFrames = (emphasizedSignal.count - frameLength) / hopLength + 1
        print("🎯 입력 길이: \(emphasizedSignal.count)")
        print("📐 프레임 수: \(numFrames)")

        let hannWindow = createHannWindow()
        var mfccs: [[Float]] = []

        for frameIndex in 0..<numFrames {
            let start = frameIndex * hopLength
            let frame = Array(emphasizedSignal[start..<start + frameLength])

            let windowed = applyWindow(to: frame, with: hannWindow)
            let (real, imag) = performFFT(on: windowed)
            let powerSpectrum = computePowerSpectrum(real: real, imag: imag)
            let melEnergies = applyMelFilterBank(to: powerSpectrum)

            let epsilon: Float = 1e-6
            let logMel = melEnergies.map { log($0 + epsilon) }

            if logMel.contains(where: { $0.isNaN || $0.isInfinite }) {
                print("🚫 로그 Mel 에너지에 NaN 또는 무한값 있음 → 프레임 \(frameIndex) 스킵")
                continue
            }

            let mfcc = computeDCT(logMel, outputCount: numCoefficients)
            mfccs.append(mfcc)
        }

        print("✅ 최종 MFCC 개수: \(mfccs.count)")
        return mfccs
    }
    
    private func createHannWindow() -> [Float] {
        var window = [Float](repeating: 0.0, count: frameLength)
        vDSP_hann_window(&window, vDSP_Length(frameLength), Int32(vDSP_HANN_NORM))
        return window
    }

    private func applyWindow(to frame: [Float], with window: [Float]) -> [Float] {
        var result = [Float](repeating: 0.0, count: frameLength)
        vDSP_vmul(frame, 1, window, 1, &result, 1, vDSP_Length(frameLength))
        return result
    }

    private func performFFT(on windowed: [Float]) -> ([Float], [Float]) {
        var realp = [Float](repeating: 0.0, count: frameLength / 2)
        var imagp = [Float](repeating: 0.0, count: frameLength / 2)

        let log2n = vDSP_Length(log2(Float(frameLength)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            print("❌ FFT setup 생성 실패")
            return (realp, imagp)
        }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        realp.withUnsafeMutableBufferPointer { realBuf in
            imagp.withUnsafeMutableBufferPointer { imagBuf in
                windowed.withUnsafeBufferPointer { inputBuf in
                    var splitComplex = DSPSplitComplex(realp: realBuf.baseAddress!, imagp: imagBuf.baseAddress!)
                    inputBuf.baseAddress?.withMemoryRebound(to: DSPComplex.self, capacity: frameLength / 2) { complexPtr in
                        vDSP_ctoz(complexPtr, 2, &splitComplex, 1, vDSP_Length(frameLength / 2))
                        vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                    }
                }
            }
        }

        return (realp, imagp)
    }

    private func computePowerSpectrum(real: [Float], imag: [Float]) -> [Float] {
        var power = [Float](repeating: 0.0, count: real.count)

        real.withUnsafeBufferPointer { realBuf in
            imag.withUnsafeBufferPointer { imagBuf in
                guard let realPtr = realBuf.baseAddress, let imagPtr = imagBuf.baseAddress else {
                    print("❌ DSPSplitComplex 포인터 생성 실패")
                    return
                }
                var splitComplex = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: realPtr),
                                                   imagp: UnsafeMutablePointer(mutating: imagPtr))
                vDSP_zvmags(&splitComplex, 1, &power, 1, vDSP_Length(real.count))
            }
        }

        return power
    }
    
    // DCT 수행 -> 저주파 정보 추출
    private func computeDCT(_ input: [Float], outputCount: Int) -> [Float] {
        let N = input.count
        var result = [Float](repeating: 0.0, count: outputCount)

        for k in 0..<outputCount {
            var sum: Float = 0.0
            for n in 0..<N {
                sum += input[n] * cos(.pi / Float(N) * (Float(n) + 0.5) * Float(k))
            }
            result[k] = sum
        }

        // DCT 결과 정규화
        let scale = sqrt(2.0 / Float(N))
        for i in 0..<outputCount {
            result[i] *= scale
        }
        result[0] *= 1.0 / sqrt(2.0)
        return result
    }
    
    private func applyMelFilterBank(to spectrum: [Float]) -> [Float] {
        let melMin = 0.0
        let melMax = 2595.0 * log10(1.0 + Double(sampleRate / 2.0) / 700.0)
        let melPoints = (0...(numMelBands + 2)).map {
            melMin + (melMax - melMin) * Double($0) / Double(numMelBands + 2)
        }
        let hzPoints = melPoints.map { 700.0 * (pow(10.0, $0 / 2595.0) - 1.0) }
        let binPoints = hzPoints.map { floor(Double(frameLength) * $0 / Double(sampleRate)) }

        var filterBank = [[Float]](repeating: [Float](repeating: 0.0, count: spectrum.count), count: numMelBands)

        for m in 1...numMelBands {
            let f_m_minus = Int(binPoints[m - 1])
            let f_m = Int(binPoints[m])
            let f_m_plus = Int(binPoints[m + 1])

            for k in f_m_minus..<f_m {
                if k >= 0 && k < spectrum.count {
                    filterBank[m - 1][k] = Float(k - f_m_minus) / Float(f_m - f_m_minus)
                }
            }
            for k in f_m..<f_m_plus {
                if k >= 0 && k < spectrum.count {
                    filterBank[m - 1][k] = Float(f_m_plus - k) / Float(f_m_plus - f_m)
                }
            }
        }

        var melEnergies = [Float](repeating: 0.0, count: numMelBands)
        for (i, filter) in filterBank.enumerated() {
            melEnergies[i] = zip(spectrum, filter).map(*).reduce(0, +)
        }
        return melEnergies
    }
}
