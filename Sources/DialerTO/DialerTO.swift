//
//  DialerOptimizer.swift
//
//  Copyright (c) 2025 Cédric Bahirwe
//
//  This software is licensed under the MIT License.
//  See the LICENSE file in the project root for more information.
//

import Foundation

public typealias TransactionFee = Int
public struct TransactionOptimizer {
    /// Calculates the transaction fee based on a predefined fee structure.
    ///
    /// The fee structure is tiered, with different fees applied to different amount ranges:
    /// - Amounts over 5,000,001: Fee of 5,000
    /// - Amounts between 2,000,001 and 5,000,000: Fee of 3,000
    /// - Amounts between 150,001 and 2,000,000: Fee of 1,500
    /// - Amounts between 10,001 and 150,000: Fee of 250
    /// - Amounts between 1,001 and 10,000: Fee of 100
    /// - Amounts between 1 and 1,000: Fee of 20
    /// - Amounts outside these ranges: Returns nil (invalid transaction)
    ///
    /// - Parameter amount: The transaction amount to calculate the fee for
    /// - Returns: The fee for the transaction, or nil if the amount is invalid
    ///
    /// # Examples:
    /// ```swift
    /// TransactionOptimizer.calculateFee(for: 5_000) // Returns 100
    /// TransactionOptimizer.calculateFee(for: 100_000) // Returns 250
    /// TransactionOptimizer.calculateFee(for: 250_000) // Returns 1,500
    /// TransactionOptimizer.calculateFee(for: 10_000_001) // Returns nil
    /// ```
    ///
    /// # Reference
    /// For the most up-to-date fee information, please check [the official MTN Mobile Money tariff](https://www.mtn.co.rw/momo-tarrif/):
    public static func calculateFee(for amount: Int) -> Int? {
        switch amount {
        case 10_000_001...: return nil
        case 5_000_001...: return 5_000
        case 2_000_001...: return 3_000
        case 150_001...: return 1_500
        case 10_001...: return 250
        case 1_001...: return 100
        case 1...: return 20
        default: return nil
        }
    }

    /// Optimizes transactions using a greedy, approximation approach
    /// - Parameter totalAmount: The total amount to be transferred
    /// - Returns: An array of transaction amounts that minimizes the total fee
    public static func optimizeTransactions(totalAmount: Int) -> [Int] {
        // Early exit if total amount is invalid
        guard totalAmount > 0, totalAmount <= 10_000_000 else {
            return []
        }

        // Predefined optimal split points based on fee brackets
        let optimalSplitPoints = [
            1...1_000,
            1_001...10_000,   // Lowest fee threshold
            10_001...150_000,  // Next significant fee change
            1_50_001...2_000_000, // Major fee bracket
            2_000_001...5_000_000,  // Highest fee bracket before max
            5_000_001...10_000_000
        ]

        var isFirstSplit = true
        var result = [Int]()
        var remainingAmount = totalAmount

        // Start with the largest possible split that doesn't exceed remaining amount
        while remainingAmount > 0 {
            // Find the largest split point that doesn't exceed remaining amount
            let splitAmount: Int
            if isFirstSplit {
                isFirstSplit = false
                splitAmount = optimalSplitPoints
                    .map(\.upperBound)
                    .filter { $0 <= remainingAmount }
                    .max() ?? remainingAmount
            } else {
                splitAmount = optimalSplitPoints
                    .filter({ remainingAmount >= $0.lowerBound })
                    .last?.upperBound ?? remainingAmount
            }

            // Ensure we don't create tiny transactions
            let finalSplitAmount = min(splitAmount, remainingAmount)

            result.append(finalSplitAmount)
            remainingAmount -= finalSplitAmount
        }

        return result
    }

    /// Calculates the total fee for a given set of transactions
    /// - Parameter transactions: Array of transaction amounts
    /// - Returns: Total fee for all transactions, or nil if any transaction is invalid
    public static func calculateTotalFee(for transactions: [Int]) -> Int? {
        var totalFee = 0
        for amount in transactions {
            guard let fee = calculateFee(for: amount) else {
                return nil
            }
            totalFee += fee
        }
        return totalFee
    }

    /// Calculates how much money the user would save by splitting the transaction
    /// - Parameter totalAmount: The total amount to be transferred
    /// - Returns: A tuple containing (savings amount, original fee, optimized fee)
    public static func calculateFeesSavings(for totalAmount: Int) -> (savings: Int, originalFee: Int, optimizedFee: Int)? {
        // Calculate original fee for single transaction
        guard let originalFee = calculateFee(for: totalAmount) else {
            return nil
        }

        // Get optimized transactions
        let optimizedTransactions = optimizeTransactions(totalAmount: totalAmount)

        // Calculate optimized total fee
        guard let optimizedFee = calculateTotalFee(for: optimizedTransactions) else {
            return nil
        }

        // Calculate savings
        let savings = originalFee - optimizedFee

        return (savings: savings, originalFee: originalFee, optimizedFee: optimizedFee)
    }
}
