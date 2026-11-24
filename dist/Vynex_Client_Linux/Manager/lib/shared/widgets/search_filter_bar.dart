import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final List<Widget>? filterActions;

  const SearchFilterBar({
    Key? key,
    this.hintText = 'Tìm kiếm nhanh...',
    required this.onSearchChanged,
    this.filterActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        // Search Input
        SizedBox(
          width: 320,
          height: 42,
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),
        ),

        // Optional Filter dropdowns / buttons
        if (filterActions != null && filterActions!.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: filterActions!,
          ),
      ],
    );
  }
}
