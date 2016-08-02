//
//  Delay.swift
//  Percolator
//


import Foundation

func delay(_ time: Double, handler: () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now(), execute: handler)
}
