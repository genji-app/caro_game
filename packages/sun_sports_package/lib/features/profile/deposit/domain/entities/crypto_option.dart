/// Crypto currency option entity for domain layer
class CryptoOption {
  final String id;
  final String name;
  final String network;
  final String iconPath;
  final String price; // Price

  const CryptoOption({
    required this.id,
    required this.name,
    required this.network,
    required this.iconPath,
    required this.price,
  });
}
