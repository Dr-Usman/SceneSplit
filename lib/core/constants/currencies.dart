class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency(this.code, this.symbol, this.name);
}

const supportedCurrencies = [
  // 🇵🇰 Pakistan (Primary)
  Currency('PKR', 'Rs', 'Pakistani Rupee'),

  // 🌍 Global Major
  Currency('USD', '\$', 'US Dollar'),
  Currency('EUR', '€', 'Euro'),
  Currency('GBP', '£', 'British Pound'),

  // 🌏 Asia (High Usage)
  Currency('INR', '₹', 'Indian Rupee'),
  Currency('CNY', '¥', 'Chinese Yuan'),
  Currency('JPY', '¥', 'Japanese Yen'),

  // 🌍 Middle East (Important for PK users)
  Currency('AED', 'د.إ', 'UAE Dirham'),
  Currency('SAR', '﷼', 'Saudi Riyal'),
  Currency('QAR', '﷼', 'Qatari Riyal'),
  Currency('KWD', 'د.ك', 'Kuwaiti Dinar'),
  Currency('OMR', '﷼', 'Omani Rial'),

  // 🌍 Western Countries
  Currency('CAD', '\$', 'Canadian Dollar'),
  Currency('AUD', '\$', 'Australian Dollar'),

  // 🌍 Europe (Extra)
  Currency('CHF', 'CHF', 'Swiss Franc'),
  Currency('TRY', '₺', 'Turkish Lira'),
];

Currency currencyByCode(String code) => supportedCurrencies.firstWhere(
  (c) => c.code == code,
  orElse: () => supportedCurrencies.first,
);
