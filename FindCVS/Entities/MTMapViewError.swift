//
//  MTMapViewError.swift
//  FindCVS
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import Foundation

enum MTMapViewError: Error {
    case failedUpdateCurrentLocation
    case locationAuthDenied
    
    var errorDescription: String {
        switch self {
        case .failedUpdateCurrentLocation:
            return "현재 위치를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요."
        case .locationAuthDenied:
            return "위치 정보를 비활성화하면 사용자의 현재 위치를 알 수 없습니다."
        }
    }
}
