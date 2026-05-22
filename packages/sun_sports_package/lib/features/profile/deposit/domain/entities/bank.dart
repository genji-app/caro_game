/// Bank entity for domain layer (without JSON serialization)
class Bank {
  final String id;
  final String name;
  final String? iconUrl;

  const Bank({required this.id, required this.name, this.iconUrl});
}
