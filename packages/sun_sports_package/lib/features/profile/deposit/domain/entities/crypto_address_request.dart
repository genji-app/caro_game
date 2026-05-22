/// Request entity for getCryptoAddress API
class CryptoAddressRequest {
  final String network; // e.g., "TRC20"
  final String currencyName; // e.g., "USDT"
  final String fiatCurrency;

  const CryptoAddressRequest({
    required this.network,
    required this.currencyName,
    required this.fiatCurrency,
  });

  Map<String, dynamic> toJson() => {
    'command': 'getCryptoAddress',
    'network': network,
    'currencyName': currencyName,
    'fiatCurrency': fiatCurrency,
  };
}
