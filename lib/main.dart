import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_login/repository/user-repository.dart';
import 'package:flutter_social_login/page/splash-page.dart';
import 'package:flutter_social_login/page/home-page.dart';
import 'package:flutter_social_login/page/login-page.dart';
import 'package:flutter_social_login/bloc/authenticate-bloc.dart';
import 'package:flutter_social_login/widget/loading-indicator.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition.toString());
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(App(userRepository: UserRepository()));
}

class App extends StatefulWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc authenticationBloc;
  UserRepository get userRepository => widget.userRepository;

  @override
  void initState() {
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    authenticationBloc.dispatch(AppStarted());
    super.initState();
  }

  @override
  void dispose() {
    authenticationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      bloc: authenticationBloc,
      child: MaterialApp(
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationUninitialized) {
              return SplashPage();
            }
            if (state is AuthenticationAuthenticated) {
              return HomePage();
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginPage(userRepository: userRepository);
            }
            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }
            return null;
          },
        ),
      ),
    );
  }
}
