import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/messages/error_snackbar.dart';
import '../../../../constants/assets.dart';
import '../../../../constants/sizing.dart';
import '../../../../theme/colors.dart';
import '../../application/signin_bloc/signin_bloc.dart';
import '../views/forgot_password_sheet.dart';
import '../widgets/appbar_title.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/field_q_button.dart';
import '../widgets/field_title.dart';
import '../widgets/or_divider.dart';
import '../widgets/service_wrapper.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _forgotPasswordEmailController;
  late final TextEditingController _passwordController;
  @override
  void initState() {
    _emailController = TextEditingController();
    _forgotPasswordEmailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _forgotPasswordEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isPasswordInvisible = true;

  @override
  Widget build(BuildContext context) {
    final _height = ScreenSize.height(context);
    final _width = ScreenSize.width(context);
    return BlocConsumer<SigninBloc, SigninState>(
      listener: (context, state) {
        if (state is SigninFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            errorSnack(state.error),
          );
        } else if (state is SigninSuccessState) {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {
              'selectedIndex': 0,
              'user': state.user,
              'posts': state.posts
            },
          );
        }
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            gradient: Pellet.kBackgroundGradient,
          ),
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: AppBarTitle(
                title: 'Sign In',
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(_height * ScreenSize.kSpaceL),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthServiceWrapper(height: _height, width: _width),
                    SizedBox(height: _height * 4),
                    OrDivider(),
                    SizedBox(height: _height * 3),
                    TextFieldTitle(title: 'Email'),
                    SizedBox(height: _height * 1),
                    AuthTextField(
                        suffixIcon:
                            state is ValidEmailState || state is ValidState
                                ? Icon(Icons.check_box, color: Pellet.kPrimary)
                                : null,
                        hintText: 'Username or email',
                        controller: _emailController,
                        onChanged: (value) {
                          context.read<SigninBloc>().add(
                                EmailOrPasswordChangedEvent(
                                  _emailController.text,
                                  _passwordController.text,
                                ),
                              );
                        }),
                    SizedBox(height: _height * 3),
                    TextFieldTitle(title: 'Password'),
                    SizedBox(height: _height * 1),
                    AuthTextField(
                        obscureText: _isPasswordInvisible,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPasswordInvisible = !_isPasswordInvisible;
                            });
                          },
                          child: Icon(_isPasswordInvisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        onChanged: (value) {
                          context.read<SigninBloc>().add(
                                EmailOrPasswordChangedEvent(
                                  _emailController.text,
                                  _passwordController.text,
                                ),
                              );
                        }),
                    SizedBox(height: _height * 1),
                    SizedBox(height: _height * 2),
                    TextFieldQButton(
                        title: 'Forgotten Password?',
                        onTapped: () {
                          forgetPasswordBottomSheet(
                              context, _forgotPasswordEmailController);
                        }),
                    SizedBox(height: _height * 6),
                    ElevatedButton(
                      onPressed: state is ValidState
                          ? () {
                              context.read<SigninBloc>().add(
                                    SigninButtonPressed(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                            }
                          : null,
                      child: state is SigninLoadingState
                          ? Lottie.asset(Assets.progressIndicator)
                          : const Text('Sign In'),
                    ),
                    SizedBox(height: _height * 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFieldTitle(title: 'Don\'t have an account? '),
                        TextFieldQButton(
                            title: 'Sign Up',
                            onTapped: () {
                              context.read<SigninBloc>().add(PageChangeEvent());
                              Navigator.pushReplacementNamed(
                                  context, '/animated-signup');
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
