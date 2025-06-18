// lib/utils/app_routes.dart

import 'package:get/get.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/note_form_screen.dart';
import '../../screens/home/notes_list_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splash_screen.dart';
import '../screens/chat_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String notes = '/notes';
  static const String noteForm = '/note-form';
  static const String chat = '/chat';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: notes, page: () => const NotesListScreen()),
    GetPage(name: noteForm, page: () => NoteFormScreen()),
    GetPage(name: chat, page: () => const ChatScreen()),
  ];
}
