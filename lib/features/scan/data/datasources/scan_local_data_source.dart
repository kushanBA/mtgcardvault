import 'package:cardvault/core/storage/local_storage.dart' as storage;

abstract class ScanLocalDataSource {
  Future<void> savePriceCategory(String cat);
  Future<String> getPriceCategory(String key);
}

class ScanLocalDataSourceImplt implements ScanLocalDataSource {
  @override
  Future<void> savePriceCategory(String cat) async {
    await storage.save("priceCat", cat);
  }

  @override
  Future<String> getPriceCategory(String key) async {
    final cat = await storage.load(key, (_) {});
    return cat;
  }
}
