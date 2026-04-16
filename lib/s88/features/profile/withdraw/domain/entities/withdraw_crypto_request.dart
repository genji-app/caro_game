/// Withdraw crypto request entity for domain layer
class WithdrawCryptoRequest {
  final String network; // Blockchain network (UPPERCASE, e.g., "TRC20")
  final String cryptoCurrency; // Tên coin (UPPERCASE, e.g., "USDT")
  final int amount; // Số tiền VND muốn rút (số nguyên)
  final String address; // Địa chỉ ví crypto nhận tiền
  final String fiatCurrency; // Luôn là "VND"

  const WithdrawCryptoRequest({
    required this.network,
    required this.cryptoCurrency,
    required this.amount,
    required this.address,
    this.fiatCurrency = 'VND',
  });
}
