//
//  GoldWatchViewModel.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 21/10/25.
//

import Foundation
import Combine

class GoldWatchViewModel: ObservableObject {
    
    @Published var gold: GoldDailyData?
    
    @Published var currentBranch: GoldBranch = .sjc
    
    init() {
    }
    
    func getDailyGold(branch: GoldBranch) {
        Task {
            do {
                let response = try await GoldService.shared.fetchGoldDaily(request: GoldDailyRequest(branch: branch.rawValue))
                
                if let data = response.data {
                    await MainActor.run {
                        gold = data
                    }
                }
            } catch {
                debugPrint("ERROR ---> GoldViewModel")
                debugPrint(error)
            }
        }
    }
    
    
    
}
