import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Manual photo upload (decision #1: no auto-fetched preview images in v1)
/// for the two lists that carry a photo — Products to Buy and Wishlist.
abstract interface class ImageUploadService {
  /// Uploads [bytes] for [itemId] and returns its download URL.
  Future<String> uploadItemImage(String itemId, List<int> bytes);

  /// Deletes the image for [itemId], if one was ever uploaded.
  Future<void> deleteItemImage(String itemId);
}

class FirebaseImageUploadService implements ImageUploadService {
  FirebaseImageUploadService(this._storage);

  final FirebaseStorage _storage;

  @override
  Future<String> uploadItemImage(String itemId, List<int> bytes) async {
    final ref = _storage.ref('item_images/$itemId.jpg');
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  @override
  Future<void> deleteItemImage(String itemId) async {
    try {
      await _storage.ref('item_images/$itemId.jpg').delete();
    } on FirebaseException catch (e) {
      // Nothing to delete — fine, the item may never have had a photo.
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
