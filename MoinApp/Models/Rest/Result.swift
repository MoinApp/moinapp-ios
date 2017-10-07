//
//  Result.swift
//  MoinApp
//
//  Created by Sören Gade on 07.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import Foundation

enum Result<T> where T : Equatable {
    case success(T)
    case error(Error)
}

extension Result : Equatable {
    static func ==(lhs: Result<T>, rhs: Result<T>) -> Bool {
        switch ( lhs, rhs ) {
        case ( let .success(v1), let .success(v2) ):
            return v1 == v2
        case ( let .error(e1), let .error(e2) ):
            return e1.localizedDescription == e2.localizedDescription
        default:
            return false
        }
    }
}
