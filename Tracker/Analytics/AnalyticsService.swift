//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Konstantin Penzin on 16.12.2023.
//

import Foundation
import YandexMobileMetrica

protocol AnalyticsServiceProtocol {
    func report(event: AnalyticsEvents, params: [AnyHashable : Any]) -> Void
}

struct AnalyticsService: AnalyticsServiceProtocol {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "b470bb7a-8e58-4bbe-a1c7-ef6385619cd7") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: AnalyticsEvents, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
