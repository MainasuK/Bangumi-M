//
//  ConsolePrint.swift
//  Percolator
//

import Foundation

func consolePrint<T>(
    _ message: @autoclosure () -> T,
    file: String   = #file,
    method: String = #function,
    line: Int      = #line) {
    #if DEBUG
        let msg = message()
        print("^ \((file as NSString).lastPathComponent)[\(line)], \(method): \(msg)", terminator: "\n")
    #endif
}
