import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_media_app/materials/app_theme.dart';
import 'package:social_media_app/routes.dart';
import 'package:social_media_app/screens/splash_screen/splash_screen.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/services/repositories/api/api_impl.dart';
import 'package:social_media_app/services/repositories/log/log.dart';
import 'package:social_media_app/services/repositories/log/log_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cubit/main_cubit/main_cubit.dart';
import 'models/profile/profile.dart';

class SimpleBlocObserver extends BlocObserver {
  const SimpleBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    print('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    print('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    print('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    print('onClose -- bloc: ${bloc.runtimeType}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const SimpleBlocObserver();
  await Supabase.initialize(
    url: 'https://dxrgzhqvlvqhlrouacup.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR4cmd6aHF2bHZxaGxyb3VhY3VwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3NDc3MDUsImV4cCI6MjA3MzMyMzcwNX0.q_jDGODJk7EZ1NGX14-_Hbg4czWRCZ6FI-lvl4vK2tc',
  );
  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter()); // adapter do build_runner sinh ra
  await Hive.openBox<Profile>('profile');

  runApp(RepositoryProvider<Log>(create: (context) => LogImpl(), child: Repository()));
}

class Repository extends StatelessWidget {
  const Repository({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Api>(
      create: (context) => ApiImpl(context.read<Log>()),
      child: BlocProvider(create: (context) => MainCubit(context.read<Api>())..getTheme(), child: Provider()),
    );
  }
}

class Provider extends StatelessWidget {
  const Provider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: MaterialScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad}),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.isLightTheme ? ThemeMode.light : ThemeMode.dark,
          onGenerateRoute: mainRoute,
          initialRoute: SplashScreen.route,
        );
      },
    );
  }
}
