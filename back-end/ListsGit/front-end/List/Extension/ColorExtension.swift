//
//  ColorExtension.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

extension Int {
    func ff(_ shift: Int) -> Double {
        return Double((self >> shift) & 0xff) / 255
    }
}

extension Color {
    init(hex: Int) {
        self.init(red: hex.ff(16), green: hex.ff(08), blue: hex.ff(00))
    }
}

extension Double {
    func interpolate(to: Double, in fraction: Double, min: Double = 0, max: Double = 1) -> Double {
        if fraction <= min {
            return self
        } else if fraction >= max {
            return to
        }
        return self + (to - self) * (fraction - min) / (max - min)
    }
}
