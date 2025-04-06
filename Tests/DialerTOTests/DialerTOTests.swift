import Testing
@testable import DialerTO

@Suite("TransactionOptimizer Tests")
struct TransactionOptimizerTests {

    // MARK: - Tests for calculateFee

    @Test("Calculates correct fees for valid amounts")
    func testCalculateFeeForValidAmounts() {
        // Test lowest bracket: 1-1,000
        #expect(TransactionOptimizer.calculateFee(for: 1) == 20)
        #expect(TransactionOptimizer.calculateFee(for: 500) == 20)
        #expect(TransactionOptimizer.calculateFee(for: 1_000) == 20)

        // Test second bracket: 1,001-10,000
        #expect(TransactionOptimizer.calculateFee(for: 1_001) == 100)
        #expect(TransactionOptimizer.calculateFee(for: 5_000) == 100)
        #expect(TransactionOptimizer.calculateFee(for: 10_000) == 100)

        // Test third bracket: 10,001-150,000
        #expect(TransactionOptimizer.calculateFee(for: 10_001) == 250)
        #expect(TransactionOptimizer.calculateFee(for: 100_000) == 250)
        #expect(TransactionOptimizer.calculateFee(for: 150_000) == 250)

        // Test fourth bracket: 150,001-2,000,000
        #expect(TransactionOptimizer.calculateFee(for: 150_001) == 1_500)
        #expect(TransactionOptimizer.calculateFee(for: 1_000_000) == 1_500)
        #expect(TransactionOptimizer.calculateFee(for: 2_000_000) == 1_500)

        // Test fifth bracket: 2,000,001-5,000,000
        #expect(TransactionOptimizer.calculateFee(for: 2_000_001) == 3_000)
        #expect(TransactionOptimizer.calculateFee(for: 3_500_000) == 3_000)
        #expect(TransactionOptimizer.calculateFee(for: 5_000_000) == 3_000)

        // Test highest bracket: 5,000,001-10,000,000
        #expect(TransactionOptimizer.calculateFee(for: 5_000_001) == 5_000)
        #expect(TransactionOptimizer.calculateFee(for: 8_000_000) == 5_000)
        #expect(TransactionOptimizer.calculateFee(for: 10_000_000) == 5_000)
    }

    @Test("Returns nil for invalid amounts")
    func testCalculateFeeForInvalidAmounts() {
        // Test amounts outside valid range
        #expect(TransactionOptimizer.calculateFee(for: 0) == nil)
        #expect(TransactionOptimizer.calculateFee(for: -1) == nil)
        #expect(TransactionOptimizer.calculateFee(for: -1000) == nil)
        #expect(TransactionOptimizer.calculateFee(for: 10_000_001) == nil)
        #expect(TransactionOptimizer.calculateFee(for: 15_000_000) == nil)
    }

    // MARK: - Tests for optimizeTransactions

    @Test("Optimizes transactions correctly")
    func testOptimizeTransactions() {
        // Small amount that doesn't need splitting
        #expect(TransactionOptimizer.optimizeTransactions(totalAmount: 500) == [500])

        // Amount that benefits from splitting exactly at thresholds
        #expect(TransactionOptimizer.optimizeTransactions(totalAmount: 2_000) == [1_000, 1_000])

        // Test with amount that crosses several brackets
        let largeAmountResult = TransactionOptimizer.optimizeTransactions(totalAmount: 6_000_000)
        #expect(largeAmountResult.count > 1)
        #expect(largeAmountResult.reduce(0, +) == 6_000_000)

        // Test with maximum allowed amount
        let maxResult = TransactionOptimizer.optimizeTransactions(totalAmount: 10_000_000)
        #expect(maxResult.reduce(0, +) == 10_000_000)

        // Test with common use case amount
        let commonCase = TransactionOptimizer.optimizeTransactions(totalAmount: 300_000)
        #expect(commonCase.reduce(0, +) == 300_000)
    }

    @Test("Returns empty array for invalid amounts")
    func testOptimizeTransactionsInvalidAmounts() {
        #expect(TransactionOptimizer.optimizeTransactions(totalAmount: 0).isEmpty)
        #expect(TransactionOptimizer.optimizeTransactions(totalAmount: -1).isEmpty)
        #expect(TransactionOptimizer.optimizeTransactions(totalAmount: 10_000_001).isEmpty)
    }

    @Test("Optimization splits at optimal fee breakpoints")
    func testOptimizationSplitPoints() {
        // Test that 11,000 splits to benefit from lower fee brackets
        let result = TransactionOptimizer.optimizeTransactions(totalAmount: 11_000)
        #expect(result.count == 2)
        #expect(result.contains(10_000))
        #expect(result.contains(1_000))

        // Test a more complex case that should use multiple brackets
        let complexResult = TransactionOptimizer.optimizeTransactions(totalAmount: 160_000)
        let totalFee = TransactionOptimizer.calculateTotalFee(for: complexResult)
        let singleTransactionFee = TransactionOptimizer.calculateFee(for: 160_000)

        #expect(complexResult.reduce(0, +) == 160_000)
        #expect(totalFee != nil && totalFee! < singleTransactionFee!)
    }

    // MARK: - Tests for calculateTotalFee

    @Test("Calculates correct total fee")
    func testCalculateTotalFee() {
        #expect(TransactionOptimizer.calculateTotalFee(for: [500]) == 20)
        #expect(TransactionOptimizer.calculateTotalFee(for: [1_000, 2_000]) == 20 + 100)
        #expect(TransactionOptimizer.calculateTotalFee(for: [5_000, 50_000, 500_000]) == 100 + 250 + 1_500)
    }

    @Test("Returns nil if any transaction is invalid")
    func testCalculateTotalFeeWithInvalidTransaction() {
        #expect(TransactionOptimizer.calculateTotalFee(for: [500, -100, 1_000]) == nil)
        #expect(TransactionOptimizer.calculateTotalFee(for: [5_000, 0, 500_000]) == nil)
        #expect(TransactionOptimizer.calculateTotalFee(for: [5_000, 50_000, 15_000_000]) == nil)
    }

    // MARK: - Tests for calculateFeesSavings

    @Test("Calculates correct fee savings")
    func testCalculateFeeSavings() {
        // Simple case where splitting doesn't save
        let smallCase = TransactionOptimizer.calculateFeesSavings(for: 500)
        #expect(smallCase?.savings == 0)
        #expect(smallCase?.originalFee == 20)
        #expect(smallCase?.optimizedFee == 20)

        // Medium case where splitting can save
        if let mediumCase = TransactionOptimizer.calculateFeesSavings(for: 11_000) {
            #expect(mediumCase.savings > 0)
            #expect(mediumCase.originalFee == 250)
            #expect(mediumCase.optimizedFee < 250)
        } else {
            #expect(Bool(false), "Medium case calculation returned nil")
        }

        // Large case with significant savings
        if let largeCase = TransactionOptimizer.calculateFeesSavings(for: 7_000_000) {
            #expect(largeCase.savings > 0)
            #expect(largeCase.originalFee == 5_000)
        } else {
            #expect(Bool(false), "Large case calculation returned nil")
        }
    }

    @Test("Returns nil for invalid amounts")
    func testCalculateFeeSavingsInvalidAmount() {
        #expect(TransactionOptimizer.calculateFeesSavings(for: 0) == nil)
        #expect(TransactionOptimizer.calculateFeesSavings(for: -500) == nil)
        #expect(TransactionOptimizer.calculateFeesSavings(for: 15_000_000) == nil)
    }

    // MARK: - Integration tests

    @Test("End-to-end transaction optimization workflow")
    func testEndToEndOptimization() {
        // Test entire workflow for a transaction amount that benefits from splitting
        let amount = 3_000_000

        // 1. Verify single transaction fee
        let singleFee = TransactionOptimizer.calculateFee(for: amount)
        #expect(singleFee == 3_000)

        // 2. Get optimized transactions
        let optimizedTransactions = TransactionOptimizer.optimizeTransactions(totalAmount: amount)
        #expect(!optimizedTransactions.isEmpty)
        #expect(optimizedTransactions.reduce(0, +) == amount)

        // 3. Calculate total fee for optimized transactions
        let optimizedFee = TransactionOptimizer.calculateTotalFee(for: optimizedTransactions)
        #expect(optimizedFee != nil)

        // 4. Calculate savings
        let savings = TransactionOptimizer.calculateFeesSavings(for: amount)
        #expect(savings != nil)
        #expect(savings!.originalFee == singleFee)
        #expect(savings!.optimizedFee == optimizedFee)
        #expect(savings!.savings == singleFee! - optimizedFee!)
    }
}
