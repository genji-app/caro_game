import 'package:flutter/material.dart';
import 'package:co_caro_flame/s88/features/search/presentations/widget/search_dialog.dart';

/// Tablet search: shows [SearchDialog] as overlay, pops route when dialog closes.
class SearchTabletScreen extends StatefulWidget {
  const SearchTabletScreen({super.key});

  @override
  State<SearchTabletScreen> createState() => _SearchTabletScreenState();
}

class _SearchTabletScreenState extends State<SearchTabletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog());
  }

  Future<void> _showDialog() async {
    if (!mounted) return;
    await SearchDialog.show(context);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
