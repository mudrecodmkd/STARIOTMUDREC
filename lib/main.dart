import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/treasury_screen.dart';
import 'services/catalog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MudrecApp());
}

class MudrecApp extends StatelessWidget {
  const MudrecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Стариот Мудрец',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E2E38), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF14141A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B1B22),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      home: const _Home(),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> with TickerProviderStateMixin {
  late final TabController _tab;
  int _quoteIndex = 0;
  Timer? _rotTimer;

  final _headerQuotes = Catalog.headerQuotes; // ротираат под насловот

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _rotTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() => _quoteIndex = (_quoteIndex + 1) % _headerQuotes.length);
    });
  }

  @override
  void dispose() {
    _rotTimer?.cancel();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final miniQuote = _headerQuotes[_quoteIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Стариот Мудрец'),
            const SizedBox(height: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: Text(
                miniQuote,
                key: ValueKey(miniQuote),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70, fontSize: 12.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Разговор'),
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Ризница'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          ChatScreen(),
          TreasuryScreen(),
        ],
      ),
    );
  }
}
