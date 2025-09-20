import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class ChatStore {
  static const _key = 'chat_history_v3';

  Future<List<Message>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Message.fromJson).toList();
  }

  Future<void> save(List<Message> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
