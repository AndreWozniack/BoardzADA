//
//  DebugOptions.swift
//  BoardzADA
//
//  Created by André Wozniack on 12/10/24.
//

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(output, terminator: terminator)
    #endif
}
