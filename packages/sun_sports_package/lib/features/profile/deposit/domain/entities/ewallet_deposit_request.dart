/// EWallet deposit request entity for domain layer
class EWalletDepositRequest {
  final String walletType; // Wallet name/ID (e.g., 'Momo', 'ZaloPay')
  final String amount;

  const EWalletDepositRequest({required this.walletType, required this.amount});
}
