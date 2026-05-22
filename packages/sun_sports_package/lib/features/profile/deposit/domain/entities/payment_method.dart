/// Payment method enum for deposit transactions
///
/// This enum represents the different payment methods available for deposits.
/// It is part of the domain layer and should not depend on data or presentation layers.
enum PaymentMethod { codepay, bank, eWallet, crypto, scratchCard, giftcode }
