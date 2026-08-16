import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LexicalRenderer extends StatelessWidget {
  final Map<String, dynamic> document;
  final TextStyle? baseStyle;

  const LexicalRenderer({
    super.key,
    required this.document,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (document['root'] == null || document['root']['children'] == null) {
      return const SizedBox.shrink();
    }

    final children = document['root']['children'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.map((node) => _buildNode(context, node)).toList(),
    );
  }

  Widget _buildNode(BuildContext context, Map<String, dynamic> node) {
    final type = node['type'] as String?;
    if (type == null) return const SizedBox.shrink();

    switch (type) {
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: RichText(
            text: TextSpan(
              style: baseStyle ?? DefaultTextStyle.of(context).style,
              children: _buildTextSpans(node['children'] as List?),
            ),
          ),
        );
      case 'heading':
        final tag = node['tag'] as String?; // h1, h2, h3...
        double fontSize = 24.0;
        FontWeight weight = FontWeight.bold;
        if (tag == 'h1') fontSize = 32.0;
        else if (tag == 'h2') fontSize = 28.0;
        else if (tag == 'h3') fontSize = 24.0;
        else if (tag == 'h4') fontSize = 20.0;
        else if (tag == 'h5') fontSize = 18.0;
        else if (tag == 'h6') fontSize = 16.0;

        return Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: RichText(
            text: TextSpan(
              style: (baseStyle ?? DefaultTextStyle.of(context).style).copyWith(
                fontSize: fontSize,
                fontWeight: weight,
                height: 1.3,
              ),
              children: _buildTextSpans(node['children'] as List?),
            ),
          ),
        );
      case 'quote':
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0, left: 8.0),
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(width: 4, color: Theme.of(context).colorScheme.primary)),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          ),
          child: RichText(
            text: TextSpan(
              style: (baseStyle ?? DefaultTextStyle.of(context).style).copyWith(
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              children: _buildTextSpans(node['children'] as List?),
            ),
          ),
        );
      case 'list':
        final listType = node['listType'] as String?; // 'bullet' or 'number'
        final listChildren = node['children'] as List?;
        if (listChildren == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: listChildren.asMap().entries.map((entry) {
              final index = entry.key;
              final listItem = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listType == 'number' ? '${index + 1}. ' : '• ',
                      style: (baseStyle ?? DefaultTextStyle.of(context).style).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: baseStyle ?? DefaultTextStyle.of(context).style,
                          children: _buildTextSpans(listItem['children'] as List?),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      case 'horizontalrule':
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        );
      default:
        // Fallback for unknown nodes that might contain text children
        if (node['children'] != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RichText(
              text: TextSpan(
                style: baseStyle ?? DefaultTextStyle.of(context).style,
                children: _buildTextSpans(node['children'] as List?),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
    }
  }

  List<TextSpan> _buildTextSpans(List<dynamic>? children) {
    if (children == null) return [];

    List<TextSpan> spans = [];
    for (var child in children) {
      if (child['type'] == 'text') {
        final text = child['text'] as String? ?? '';
        final format = child['format'] as int? ?? 0;
        // Lexical formats: 1: bold, 2: italic, 4: strikethrough, 8: underline, 16: code, 32: subscript, 64: superscript
        
        FontWeight weight = FontWeight.normal;
        FontStyle style = FontStyle.normal;
        TextDecoration decoration = TextDecoration.none;

        if ((format & 1) != 0) weight = FontWeight.bold;
        if ((format & 2) != 0) style = FontStyle.italic;
        if ((format & 4) != 0) decoration = TextDecoration.lineThrough;
        if ((format & 8) != 0) {
          decoration = decoration == TextDecoration.lineThrough
              ? TextDecoration.combine([TextDecoration.lineThrough, TextDecoration.underline])
              : TextDecoration.underline;
        }
        
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: weight,
            fontStyle: style,
            decoration: decoration,
          ),
        ));
      } else if (child['type'] == 'link') {
        // Basic link support (could be enhanced with a gesture recognizer)
        spans.add(TextSpan(
          style: TextStyle(
            color: Colors.blue, // Primary color should ideally be passed in
            decoration: TextDecoration.underline,
          ),
          children: _buildTextSpans(child['children'] as List?),
        ));
      }
    }
    return spans;
  }
}
