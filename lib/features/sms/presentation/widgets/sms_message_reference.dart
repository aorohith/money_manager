import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

/// Shows the original bank/UPI notification text so the user can verify
/// the parsed transaction before saving.
class SmsMessageReference extends StatefulWidget {
  const SmsMessageReference({
    super.key,
    required this.rawText,
    this.senderAddress,
    this.initiallyExpanded = true,
    this.expandable = false,
  });

  final String rawText;
  final String? senderAddress;

  /// When [expandable] is true, starts collapsed if false.
  final bool initiallyExpanded;

  /// When true, shows a toggle header instead of always showing the body.
  final bool expandable;

  @override
  State<SmsMessageReference> createState() => _SmsMessageReferenceState();
}

class _SmsMessageReferenceState extends State<SmsMessageReference> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded || !widget.expandable;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rawText.trim().isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Semantics(
      label: 'Original message reference',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.expandable)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs + 2,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sms_outlined, size: 14, color: secondary),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Original message',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                          ),
                        ),
                        Icon(
                          _expanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 18,
                          color: secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(Icons.sms_outlined, size: 14, color: secondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Original message',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                    ),
                  ],
                ),
              ),
            if (_expanded) ...[
              Divider(
                height: 1,
                color: isDark ? AppColors.outlineDark : AppColors.outline,
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.senderAddress != null &&
                        widget.senderAddress!.trim().isNotEmpty) ...[
                      Text(
                        widget.senderAddress!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: secondary,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    SelectableText(
                      widget.rawText.trim(),
                      key: const Key('sms_message_reference_body'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: primary,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
