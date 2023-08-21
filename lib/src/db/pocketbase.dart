import 'package:connectopia/src/db/shared_prefs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseSingleton {
  static PocketBase? _pocketBase;

  static Future<PocketBase> get instance async {
    if (_pocketBase == null) {
      final _prefs = await SharedPrefs.instance;

      final store = AsyncAuthStore(
        save: (String data) async => _prefs.setString('pb_auth', data),
        initial: _prefs.getString('pb_auth'),
      );

      _pocketBase = PocketBase(dotenv.env['POCKETBASE_URL']!, authStore: store);
    }
    return _pocketBase!;
  }
}
