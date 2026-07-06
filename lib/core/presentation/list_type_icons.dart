import 'package:flutter/material.dart';

import '../domain/entities/list_type.dart';

/// Presentation-layer counterpart to [ListTypeDisplayName] — split out
/// because `IconData` pulls in Flutter, which the domain layer otherwise
/// doesn't depend on.
extension ListTypeIcon on ListType {
  IconData get icon => switch (this) {
    ListType.grocery => Icons.local_grocery_store_outlined,
    ListType.packing => Icons.luggage_outlined,
    ListType.admin => Icons.checklist_outlined,
    ListType.productsToBuy => Icons.shopping_bag_outlined,
    ListType.wishlist => Icons.favorite_border,
  };
}
