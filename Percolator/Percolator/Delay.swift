//
//  Delay.swift
//  Percolator
//

import Foundation

func delay(_ time: Double, handler: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: handler)
}
