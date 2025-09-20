import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../storage/chat_store.dart';
import '../services/mudrec_brain.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _id = const Uuid();
  final _store = ChatStore();
  final _brain = MudrecBrain();

  final _c = TextEditingController();
  final _scroll = ScrollController();
  List<Message> _list = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _list = await _store.load();
    if (_list.isEmpty) {
      _list.add(Message(fromUser: false, text: 'Добредојде. Кажи ми — за што да зборуваме?', time: DateTime.now()));
    }
    setState(() => _loading = false);
  }

  Future<void> _send() async {
    final txt = _c.text.trim();
    if (txt.isEmpty || _sending) return;
    _c.clear();

    setState(() {
      _list.add(Message(fromUser: true, text: txt, time: DateTime.now()));
      _sending = true;
    });
    await _store.save(_list);
    _scrollToEnd();

    await Future.delayed(const Duration(milliseconds: 300)); // природна пауза

    final answer = _brain.answer(txt);

    setState(() {
      _list.add(Message(fromUser: false, text: answer, time: DateTime.now()));
      _sending = false;
    });
    await _store.save(_list);
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Исчисти разговор?'),
        content: const Text('Ќе се избрише и локалната историја.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Откажи')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Исчисти')),
        ],
      ),
    );
    if (ok == true) {
      await _store.clear();
      setState(() => _list = [Message(fromUser: false, text: 'Започнуваме одново.', time: DateTime.now())]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Container(
          color: const Color(0xFF1E1E26),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              const Text('Стариот Мудрец', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const Spacer(),
              IconButton(tooltip: 'Исчисти', onPressed: _clear, icon: const Icon(Icons.delete_outline)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _list.length,
            itemBuilder: (_, i) {
              final m = _list[i];
              final me = m.fromUser;
              return Align(
                alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                child: GestureDetector(
                  onLongPress: () async {
                    await Clipboard.setData(ClipboardData(text: m.text));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Копирано.')));
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(
                      color: me ? const Color(0xFF3558A5) : const Color(0xFF2A2A33),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text, style: const TextStyle(fontSize: 15.5)),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Напиши му на мудрецот…',
                      filled: true,
                      fillColor: Color(0xFF1F1F27),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Испрати'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
