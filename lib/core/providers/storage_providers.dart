import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/image_upload_service.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) => FirebaseStorage.instance;

@Riverpod(keepAlive: true)
ImageUploadService imageUploadService(Ref ref) {
  return FirebaseImageUploadService(ref.watch(firebaseStorageProvider));
}
