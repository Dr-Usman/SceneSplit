class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency(this.code, this.symbol, this.name);
}

const supportedCurrencies = [
  Currency('PKR', 'Rs', 'Pakistani Rupee'),
  Currency('USD', '\$', 'US Dollar'),
  Currency('EUR', '€', 'Euro'),
  Currency('GBP', '£', 'British Pound'),
  Currency('AED', 'د.إ', 'UAE Dirham'),
  Currency('SAR', '﷼', 'Saudi Riyal'),
  Currency('INR', '₹', 'Indian Rupee'),
  Currency('TRY', '₺', 'Turkish Lira'),
];

Currency currencyByCode(String code) => supportedCurrencies.firstWhere(
  (c) => c.code == code,
  orElse: () => supportedCurrencies.first,
);
