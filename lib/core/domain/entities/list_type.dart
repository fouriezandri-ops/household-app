/// The five synced lists, discriminating rows in the shared `items`
/// collection. [value] is the exact string stored in Firestore.
enum ListType {
  grocery('grocery'),
  packing('packing'),
  admin('admin'),
  productsToBuy('products_to_buy'),
  wishlist('wishlist');

  const ListType(this.value);

  final String value;

  static ListType fromValue(String value) {
    return ListType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown ListType value: $value'),
    );
  }
}

/// Human-readable name — domain-safe (no Flutter dependency); see
/// `lib/core/presentation/list_type_icons.dart` for the matching icon,
/// which does need one.
extension ListTypeDisplayName on ListType {
  String get displayName => switch (this) {
    ListType.grocery => 'Grocery',
    ListType.packing => 'Packing',
    ListType.admin => 'Admin To-Do',
    ListType.productsToBuy => 'Products to Buy',
    ListType.wishlist => 'Wishlist',
  };
}
