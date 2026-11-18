import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import 'search_panel.dart';

/// Stand-alone search (admin dashboard search bar, map, etc.).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.searchTitle)),
      body: const SearchPanel(
        autofocus: true,
        includeArchived: true,
        header: SizedBox.shrink(),
        idle: Column(children: [SearchTips(), RecentCustomers()]),
      ),
    );
  }
}
