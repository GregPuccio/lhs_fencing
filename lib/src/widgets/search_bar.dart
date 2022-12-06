import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchBar extends ConsumerWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final String text;

  const SearchBar(
    this.controller, {
    this.text = 'Search by name',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 5),
      child: CupertinoSearchTextField(
        style: const TextStyle(color: CupertinoColors.systemGrey),
        prefixInsets: const EdgeInsetsDirectional.fromSTEB(8, 2, 4, 2),
        placeholder: text,
        controller: controller,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
