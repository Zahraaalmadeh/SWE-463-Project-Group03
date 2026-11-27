import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../theme/app_theme.dart';
import 'shared_bottom_navigation_bar.dart';

/// Layout shared by the trip sub-pages (Family members, Return checklist):
/// the top bar, a back link, a large heading with an optional subtitle, and
/// the page content in an 880px column.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.backLabel,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String backLabel;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gutter = AppLayout.gutter(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SharedSiteHeader(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              Navigator.of(context).pushReplacementNamed(
                index == 0 ? AppRoutes.home : AppRoutes.templates,
              );
            },
          ),
          Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 880),
              padding: EdgeInsets.fromLTRB(gutter, 36, gutter, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackLink(label: backLabel),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: AppText.display.copyWith(
                      fontSize: 46,
                      height: 1.08,
                      letterSpacing: -0.92,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Go back',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        hoverColor: Colors.transparent,
        onTap: () {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            navigator.pushReplacementNamed(AppRoutes.home);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 18, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pill text field with a button beside it, e.g. "Family member name  Add".
class PillInputRow extends StatelessWidget {
  const PillInputRow({
    super.key,
    required this.controller,
    required this.hint,
    required this.buttonLabel,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hint;
  final String buttonLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder pill(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: color, width: width),
        );
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              style: const TextStyle(color: AppColors.ink, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: pill(AppColors.fieldBorder),
                enabledBorder: pill(AppColors.fieldBorder),
                focusedBorder: pill(AppColors.primary, 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.add, size: 18),
            label: Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}

/// White rounded sheet with a hairline between rows, like the checklist.
class SheetCard extends StatelessWidget {
  const SheetCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
            child,
          ],
        ],
      ),
    );
  }
}

/// Centered title + explanation for empty or not-available states.
class PageMessage extends StatelessWidget {
  const PageMessage({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.cardTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// A red error line with an icon, for failures the user should notice.
class InlineError extends StatelessWidget {
  const InlineError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, size: 18, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.error, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
