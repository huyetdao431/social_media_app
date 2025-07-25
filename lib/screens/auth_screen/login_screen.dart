import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/main_cubit/main_cubit.dart';

class LoginScreen extends StatefulWidget {
  static const String route = 'LoginScreen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        var isLightTheme = state.isLightTheme;
        return Scaffold(
          appBar: AppBar(
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(child: Text(LoginScreen.route),),
              CheckboxListTile(value: isLightTheme, onChanged: (value) {
                setState(() {
                  context.read<MainCubit>().switchTheme();
                });
              }, title: Text('Light theme'),)
            ],
          ),
        );
      },
    );
  }
}
