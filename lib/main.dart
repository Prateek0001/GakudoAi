import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rx_logix/constants/storage_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/app_bloc_observer.dart';
import 'constants/string_constants.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth/auth_repository.dart';
import 'repositories/auth/auth_repository_impl.dart';
import 'repositories/chat/chat_repository.dart';
import 'repositories/chat/chat_repository_impl.dart';
import 'bloc/quiz_bloc.dart';
import 'bloc/booking_bloc.dart';
import 'bloc/payment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  final prefs = await SharedPreferences.getInstance();
  
  // Check session validity
  final token = prefs.getString(StorageConstants.authToken);
  bool isValidSession = false;
  
  if (token != null) {
    try {
      final authRepo = AuthRepositoryImpl();
      await authRepo.getUserProfile(token);
      isValidSession = true;
    } catch (e) {
      // Session invalid or expired
      await prefs.remove(StorageConstants.authToken);
      isValidSession = false;
    }
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => QuizBloc()),
          BlocProvider(create: (context) => BookingBloc()),
          BlocProvider(create: (context) => PaymentBloc()),
        ],
        child: ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (context, child) => MyApp(prefs, isValidSession),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final bool isValidSession;

  const MyApp(this.prefs, this.isValidSession, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstants.appName,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: context.watch<ThemeProvider>().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      initialRoute: isValidSession ? '/dashboard' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/chat': (context) => BlocProvider(
              create: (context) => ChatBloc(
                prefs,
                context.read<ChatRepository>(),
              ),
              child: const ChatScreen(),
            ),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
