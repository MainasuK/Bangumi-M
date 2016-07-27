//
//  Delay.swift
//  Percolator
//


import Foundation

func delay(_ time: Double, handler: () -> Void) {
    DispatchQueue.main.after(when: .now() + time, execute: handler)
}
