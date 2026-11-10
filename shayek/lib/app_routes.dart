import 'package:flutter/material.dart';

import 'models/trip.dart';
import 'models/packing_template.dart';
import 'screens/checklist_screen.dart';
import 'screens/create_trip_screen.dart';
import 'screens/family_members_screen.dart';
import 'screens/navigation_shell.dart';
import 'screens/return_checklist_screen.dart';
import 'screens/template_editor_screen.dart';

class AppRoutes {
  static const home = '/';
  static const createTrip = '/create-trip';
  static const checklist = '/checklist';
  static const templates = '/templates';
  static const family = '/family';
  static const returnChecklist = '/return-checklist';
  static const templateEditor = '/template-editor';

  const AppRoutes._();

  static Route<void> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _page(settings, const NavigationShell());
      case AppRoutes.createTrip:
        final template = settings.arguments is PackingTemplate
            ? settings.arguments! as PackingTemplate
            : null;
        return _page(settings, CreateTripScreen(template: template));
      case AppRoutes.checklist:
        final arguments = settings.arguments;
        final routeArgs = arguments is ChecklistRouteArgs
            ? arguments
            : arguments is Trip
            ? ChecklistRouteArgs(trip: arguments)
            : null;
        return _page(
          settings,
          ChecklistScreen(trip: routeArgs?.trip, template: routeArgs?.template),
        );
      case AppRoutes.templates:
        return _page(settings, const NavigationShell(initialTabIndex: 1));
      case AppRoutes.family:
        return _page(settings, const FamilyMembersScreen());
      case AppRoutes.returnChecklist:
        return _page(settings, const ReturnChecklistScreen());
      case AppRoutes.templateEditor:
        return _page(settings, const TemplateEditorScreen());
      default:
        return _page(settings, const NavigationShell());
    }
  }

  static PageRoute<void> _page(RouteSettings settings, Widget child) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 140),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (_, _, _) => child,
      transitionsBuilder: (_, animation, _, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final isTransitioning = animation.value < 1;
            return Stack(
              fit: StackFit.expand,
              children: [
                child,
                if (isTransitioning)
                  ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class ChecklistRouteArgs {
  const ChecklistRouteArgs({required this.trip, this.template});

  final Trip trip;
  final PackingTemplate? template;
}
