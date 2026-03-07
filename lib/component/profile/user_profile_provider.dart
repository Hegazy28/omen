import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String kUserProfileBoxName = 'user_profile_box';
const String _kUserNameKey = 'user_name';

Future<void> initUserProfileStorage() async {
  if (!Hive.isBoxOpen(kUserProfileBoxName)) {
    await Hive.openBox(kUserProfileBoxName);
  }
}

class UserProfileNotifier extends Notifier<String?> {
  Box<dynamic> get _box => Hive.box(kUserProfileBoxName);

  @override
  String? build() {
    final raw = _box.get(_kUserNameKey);
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  void setName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    state = clean;
    _box.put(_kUserNameKey, clean);
  }

  void clear() {
    state = null;
    _box.delete(_kUserNameKey);
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, String?>(
  UserProfileNotifier.new,
);
