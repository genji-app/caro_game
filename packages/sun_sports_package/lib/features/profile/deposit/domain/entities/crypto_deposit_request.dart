/// Crypto deposit request entity for domain layer
class CryptoDepositRequest {
  final String cryptoType; // Crypto ID (e.g., 'usdt-trc20')
  final String amount;
  final String depositAddress; // Wallet address for deposit

  const CryptoDepositRequest({
    required this.cryptoType,
    required this.amount,
    required this.depositAddress,
  });
}
