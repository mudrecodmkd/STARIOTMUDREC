import 'package:flutter/material.dart';
import '../services/catalog.dart';

class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});

  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  String _query = '';
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final all = Catalog.treasury;
    final filtered = all.where((t) {
      final okCat = _filter == null || t.category == _filter;
      final okText = _query.isEmpty || t.text.toLowerCase().contains(_query.toLowerCase());
      return okCat && okText;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Пребарај во ризницата…',
              filled: true,
              fillColor: Color(0xFF1F1F27),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: Catalog.categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final label = i == 0 ? 'Сите' : Catalog.categories[i - 1];
              final selected = i == 0 ? _filter == null : _filter == label;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => _filter = i == 0 ? null : label),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final q = filtered[i];
              return Card(
                color: const Color(0xFF20202A),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(q.text),
                  subtitle: Text('Категорија: ${q.category}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
