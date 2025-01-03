import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final String text;

  const SearchBarWidget(
    this.controller, {
    this.text = 'Search by name',
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 5),
      child: CupertinoSearchTextField(
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? CupertinoColors.black
              : CupertinoColors.white,
        ),
        prefixInsets: const EdgeInsetsDirectional.fromSTEB(8, 2, 4, 2),
        placeholder: text,
        controller: controller,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
