//
//  WalletManager.swift
//  GiaVangVN
//
//  Created by ORL on 23/10/25.
//

import Foundation
import Combine
import CoreData

// Manager gold wallet. All data saved to Coredata
// List transaction buy and sell for calculator Profit/Loss

enum TransactionType: String {
    case buy = "buy"
    case sell = "sell"
}

struct GoldTransactionModel: Identifiable {
    let id: UUID
    let transactionType: TransactionType
    let goldProduct: GoldBuyerProduct
    let quantity: Double
    let quantitySold: Double
    let unitPrice: Double
    let totalAmount: Double
    let transactionDate: Date
    let createdAt: Date
    let notes: String?
    let relatedBuyTransactionId: UUID?

    var remainingQuantity: Double {
        quantity - quantitySold
    }

    var isFullySold: Bool {
        quantitySold >= quantity
    }
}

@MainActor
class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published var buyTransactions: [GoldTransactionModel] = []
    @Published var sellTransactions: [GoldTransactionModel] = []

    private let viewContext: NSManagedObjectContext

    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
        loadTransactions()
    }

    // MARK: - Public Methods

    /// Add a new buy transaction
    func addBuyTransaction(
        goldProduct: GoldBuyerProduct,
        quantity: Double,
        unitPrice: Double,
        transactionDate: Date,
        notes: String?
    ) {
        let transaction = GoldTransaction(context: viewContext)
        transaction.id = UUID()
        transaction.transactionType = TransactionType.buy.rawValue
        transaction.goldProductRawValue = goldProduct.rawValue
        transaction.quantity = quantity
        transaction.quantitySold = 0
        transaction.unitPrice = unitPrice
        transaction.totalAmount = quantity * unitPrice
        transaction.transactionDate = transactionDate
        transaction.createdAt = Date()
        transaction.notes = notes

        saveContext()
        loadTransactions()
    }

    /// Add a sell transaction for a specific buy transaction
    func addSellTransaction(
        buyTransaction: GoldTransactionModel,
        quantityToSell: Double,
        unitPrice: Double,
        transactionDate: Date,
        notes: String?
    ) -> Bool {
        // Validate quantity
        guard quantityToSell > 0 && quantityToSell <= buyTransaction.remainingQuantity else {
            return false
        }

        // Create sell transaction
        let sellTx = GoldTransaction(context: viewContext)
        sellTx.id = UUID()
        sellTx.transactionType = TransactionType.sell.rawValue
        sellTx.goldProductRawValue = buyTransaction.goldProduct.rawValue
        sellTx.quantity = quantityToSell
        sellTx.quantitySold = 0
        sellTx.unitPrice = unitPrice
        sellTx.totalAmount = quantityToSell * unitPrice
        sellTx.transactionDate = transactionDate
        sellTx.createdAt = Date()
        sellTx.notes = notes
        sellTx.relatedBuyTransactionId = buyTransaction.id

        // Update the buy transaction's sold quantity
        updateBuyTransactionSoldQuantity(buyTransactionId: buyTransaction.id, additionalSold: quantityToSell)

        saveContext()
        loadTransactions()

        return true
    }

    /// Delete a transaction
    func deleteTransaction(_ transaction: GoldTransactionModel) {
        let fetchRequest: NSFetchRequest<GoldTransaction> = GoldTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)

        do {
            let results = try viewContext.fetch(fetchRequest)
            for result in results {
                // If deleting a sell transaction, update the related buy transaction
                if transaction.transactionType == .sell,
                   let buyId = transaction.relatedBuyTransactionId {
                    updateBuyTransactionSoldQuantity(buyTransactionId: buyId, additionalSold: -transaction.quantity)
                }

                viewContext.delete(result)
            }
            saveContext()
            loadTransactions()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }

    /// Get all buy transactions that have remaining quantity
    func getAvailableBuyTransactions() -> [GoldTransactionModel] {
        return buyTransactions.filter { !$0.isFullySold }
    }

    /// Calculate total investment (total buy amount)
    func getTotalInvestment() -> Double {
        return buyTransactions.reduce(0) { $0 + $1.totalAmount }
    }

    /// Calculate total sold amount
    func getTotalSoldAmount() -> Double {
        return sellTransactions.reduce(0) { $0 + $1.totalAmount }
    }

    /// Calculate total profit/loss
    func getTotalProfitLoss() -> Double {
        return getTotalSoldAmount() - sellTransactions.reduce(0) { sum, sellTx in
            guard let buyTx = buyTransactions.first(where: { $0.id == sellTx.relatedBuyTransactionId }) else {
                return sum
            }
            return sum + (sellTx.quantity * buyTx.unitPrice)
        }
    }

    /// Calculate unrealized profit/loss based on current market price
    func getUnrealizedProfitLoss(currentPrices: [GoldBuyerProduct: Double]) -> Double {
        return buyTransactions.reduce(0) { sum, buyTx in
            guard !buyTx.isFullySold,
                  let currentPrice = currentPrices[buyTx.goldProduct] else {
                return sum
            }
            let currentValue = buyTx.remainingQuantity * currentPrice
            let costBasis = buyTx.remainingQuantity * buyTx.unitPrice
            return sum + (currentValue - costBasis)
        }
    }

    // MARK: - Private Methods

    private func loadTransactions() {
        let fetchRequest: NSFetchRequest<GoldTransaction> = GoldTransaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \GoldTransaction.transactionDate, ascending: false)]

        do {
            let results = try viewContext.fetch(fetchRequest)

            var buys: [GoldTransactionModel] = []
            var sells: [GoldTransactionModel] = []

            for tx in results {
                guard let id = tx.id,
                      let typeStr = tx.transactionType,
                      let type = TransactionType(rawValue: typeStr),
                      let productRawValue = tx.goldProductRawValue,
                      let goldProduct = GoldBuyerProduct(rawValue: productRawValue),
                      let transactionDate = tx.transactionDate,
                      let createdAt = tx.createdAt else {
                    continue
                }

                let model = GoldTransactionModel(
                    id: id,
                    transactionType: type,
                    goldProduct: goldProduct,
                    quantity: tx.quantity,
                    quantitySold: tx.quantitySold,
                    unitPrice: tx.unitPrice,
                    totalAmount: tx.totalAmount,
                    transactionDate: transactionDate,
                    createdAt: createdAt,
                    notes: tx.notes,
                    relatedBuyTransactionId: tx.relatedBuyTransactionId
                )

                if type == .buy {
                    buys.append(model)
                } else {
                    sells.append(model)
                }
            }

            buyTransactions = buys
            sellTransactions = sells
        } catch {
            print("Error loading transactions: \(error)")
        }
    }

    private func updateBuyTransactionSoldQuantity(buyTransactionId: UUID, additionalSold: Double) {
        let fetchRequest: NSFetchRequest<GoldTransaction> = GoldTransaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", buyTransactionId as CVarArg)

        do {
            let results = try viewContext.fetch(fetchRequest)
            if let buyTx = results.first {
                buyTx.quantitySold += additionalSold
            }
        } catch {
            print("Error updating buy transaction sold quantity: \(error)")
        }
    }

    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
