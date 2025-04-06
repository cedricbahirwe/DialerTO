# DialerTO

A Swift package that provides an optimization algorithm used in [Dialer](https://github.com/cedricbahirwe/dialer) App Transactions. 

It is designed to minimize transaction fees when sending mobile money in regions with tiered transaction fee structures (such as [MTN Mobile Money](https://www.mtn.co.rw/momo-tarrif/)). The algorithm takes a total amount and splits it into smaller transactions that collectively incur the lowest possible fees.

## Features

- **Tiered Fee Calculation**: Determines the transaction fee based on a predefined fee structure.
- **Transaction Optimization**: Splits transactions into optimal amounts to reduce overall fees using a greedy, approximation algorithm.
- **Fee Savings Calculation**: Computes the savings achieved by splitting a transaction versus executing it as a single transaction.

## Usage

After adding the package to your project, import the package and use its functions as shown below:

```swift
import DialerTO

// Calculate fee for a single transaction
if let fee = TransactionOptimizer.calculateFee(for: 100_000) {
    print("Fee: \(fee)")
} else {
    print("Invalid transaction amount")
}

// Optimize a large transaction into multiple transactions
let totalAmount = 500_000
let optimizedTransactions = TransactionOptimizer.optimizeTransactions(totalAmount: totalAmount)
print("Optimized Transactions: \(optimizedTransactions)")

// Calculate fee savings
if let feesInfo = TransactionOptimizer.calculateFeesSavings(for: totalAmount) {
    print("Original Fee: \(feesInfo.originalFee)")
    print("Optimized Fee: \(feesInfo.optimizedFee)")
    print("Savings: \(feesInfo.savings)")
} else {
    print("Invalid total amount")
}
```

## API Reference

### `TransactionOptimizer`

- **`calculateFee(for amount: Int) -> Int?`**  
  Returns the fee for a given transaction amount based on a tiered fee structure. If the amount is out of the valid range, it returns `nil`.

- **`optimizeTransactions(totalAmount: Int) -> [Int]`**  
  Splits the total amount into an array of transaction amounts that minimizes the overall fee. Returns an empty array if the total amount is invalid.

- **`calculateTotalFee(for transactions: [Int]) -> Int?`**  
  Computes the total fee for an array of transaction amounts. Returns `nil` if any transaction is invalid.

- **`calculateFeesSavings(for totalAmount: Int) -> (savings: Int, originalFee: Int, optimizedFee: Int)?`**  
  Calculates how much money is saved by splitting the transaction into optimized parts, returning a tuple containing the savings, the original fee, and the optimized fee. Returns `nil` if the total amount is invalid.

## Examples

For a practical example of how to use **DialerTO**, Check the `Dialer` App on [Appstore](https://apps.apple.com/app/dial-it/id1591756747) or  [Github](https://github.com/cedricbahirwe/dialer).

## License

This project is licensed under the MIT License. If you use or modify this package, please retain the original copyright.

## Contributing

Contributions are welcome! Please fork the repository and submit your pull requests. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository.
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -am 'Add new feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a pull request.
