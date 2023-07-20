//
//  FileManagerExtensions.swift
//  BucketList
//
//  Created by Radu Petrisel on 20.07.2023.
//

import Foundation

extension FileManager {
    static var documetsDirectory: URL {
        Self.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
