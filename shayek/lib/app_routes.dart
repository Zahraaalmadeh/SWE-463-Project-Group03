import 'package:flutter/material.dart';

import 'models/trip.dart';
import 'screens/checklist_screen.dart';
import 'screens/create_trip_screen.dart';
import 'screens/family_members_screen.dart';
import 'screens/navigation_shell.dart';
import 'screens/return_checklist_screen.dart';

class AppRoutes {
  static const home = '/';
  static const createTrip = '/create-trip';
  static const checklist = '/checklist';
  static const templates = '/templates';
  static const family = '/family';
  static const returnChecklist = '/return-checklist';

  static Route<void> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _page(settings, const NavigationShell());
      case createTrip:
        return _page(settings, const CreateTripScreen());
      case checklist:
        final trip = settings.arguments is Trip ? settings.arguments! as Trip : null;
        return _page(settings, ChecklistScreen(trip: trip));
      case templates:
        return _page(settings, const NavigationShell(initialTabIndex: 1));
      case family:
        return _page(settings, const FamilyMembersScreen());
      case returnChecklist:
        return _page(settings, const ReturnChecklistScreen());
      default:
        return _page(settings, const NavigationShell());
    }
  }

  static MaterialPageRoute<void> _page(RouteSettings settings, Widget child) {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => child);
  }
}
