//
//  DialerTOMeasure.swift
//  DialerTO
//
//  Created by Cédric Bahirwe on 06/04/2025.
//

import Testing
import XCTest
import Foundation
@testable import DialerTO

@Suite
struct TransactionOptimizerBenchmarks {
    struct OptimizationResult {
        let amount: Int
        let optimizedTransactions: [Int]
        let defaultFee: Int
        let totalFee: Int
        let executionTimeMs: Double
    }

    // Replaces demonstrateOptimization
    static func benchmarkOptimization(for amount: Int) -> OptimizationResult? {
        let startTime = CFAbsoluteTimeGetCurrent()

        let optimizedTransactions = TransactionOptimizer.optimizeTransactions(totalAmount: amount)

        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = (endTime - startTime) * 1000 // ms

        guard
            let defaultFee = TransactionOptimizer.calculateFee(for: amount),
            let totalFee = TransactionOptimizer.calculateTotalFee(for: optimizedTransactions)
        else {
            return nil
        }

        return OptimizationResult(
            amount: amount,
            optimizedTransactions: optimizedTransactions,
            defaultFee: defaultFee,
            totalFee: totalFee,
            executionTimeMs: executionTime
        )
    }

    @Test
    func performanceTest() throws {
        let testAmounts = [
            1_000,
            10_000,
            100_000,
            1_000_000,
            5_000_000,
            10_000_000
        ]

        for amount in testAmounts {
            guard let result = Self.benchmarkOptimization(for: amount) else {
                throw NSError(
                    domain: "TransactionOptimizerError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to benchmark optimization for amount: \(amount)"]
                )

            }

            print("Amount: \(result.amount)")
            print("Optimized transactions: \(result.optimizedTransactions)")
            print("Default fee: \(result.defaultFee), Optimized fee: \(result.totalFee)")
            print("Transactions sum: \(result.optimizedTransactions.reduce(0, +))")
            print("Execution time: \(String(format: "%.4f", result.executionTimeMs)) ms")

            // Optional expectations
            #expect(result.optimizedTransactions.reduce(0, +) == result.amount)
            #expect(result.totalFee <= result.defaultFee)

            for transaction in result.optimizedTransactions {
                if let fee = TransactionOptimizer.calculateFee(for: transaction) {
                    print("  - Transaction \(transaction): Fee = \(fee)")
                }
            }

            print("---")
        }
    }
}
