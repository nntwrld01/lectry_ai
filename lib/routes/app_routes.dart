import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/notes_library/notes_library.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/note_capture/note_capture.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String authenticationScreen = '/authentication-screen';
  static const String notesLibrary = '/notes-library';
  static const String homeDashboard = '/home-dashboard';
  static const String profileSettings = '/profile-settings';
  static const String noteCapture = '/note-capture';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    authenticationScreen: (context) => const AuthenticationScreen(),
    notesLibrary: (context) => const NotesLibrary(),
    homeDashboard: (context) => const HomeDashboard(),
    profileSettings: (context) => const ProfileSettings(),
    noteCapture: (context) => const NoteCapture(),
    // TODO: Add your other routes here
  };
}
