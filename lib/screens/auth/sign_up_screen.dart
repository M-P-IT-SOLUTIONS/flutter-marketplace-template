import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/view_models/auth_view_model.dart';
import 'package:flutter_marketplace_template/screens/auth/sign_in_screen.dart';
import 'package:flutter_marketplace_template/screens/loading_screen.dart';
import 'package:flutter_marketplace_template/views/components/auth_text_field.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/views/components/error_message_widget.dart';

/// Screen for signing up, where user enters email and password to create an account,
/// also has option to go to sign in screen if user already has an account
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen()
        : Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: CustomAppBar(
            showTitle: false,
            showMenu: false,
            showChat: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Positioned(
                    top: 18,
                    left: 28,
                    right: 28,
                    child: Container(
                      width: 337,
                      height: 420,
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(16, 20, 94, 0.25),
                            blurRadius: 3,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 9),
                            child: Text(
                              AppLocalizations.of(context)!.register,
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 24,
                                letterSpacing: -1,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 0.5,
                            color: const Color.fromRGBO(195, 196, 215, 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 9),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                AuthTextField(
                                  controller: emailController,
                                  errorMessage:
                                      context
                                          .watch<AuthViewModel>()
                                          .emailErrorMessage,
                                  isPassword: false,
                                ),
                                Consumer<AuthViewModel>(
                                  builder:
                                      (context, value, child) =>
                                          errorMessageWidget(
                                            value.emailErrorMessage,
                                            context,
                                          ),
                                ),
                                const SizedBox(height: 6),
                                AuthTextField(
                                  controller: passwordController,
                                  errorMessage:
                                      context
                                          .watch<AuthViewModel>()
                                          .passwordErrorMessage,
                                  isPassword: true,
                                ),
                                Consumer<AuthViewModel>(
                                  builder:
                                      (context, value, child) =>
                                          errorMessageWidget(
                                            value.passwordErrorMessage,
                                            context,
                                          ),
                                ),
                                const SizedBox(height: 6),
                                AuthTextField(
                                  controller: confirmPasswordController,
                                  errorMessage:
                                      context
                                          .watch<AuthViewModel>()
                                          .confirmPasswordErrorMessage,
                                  isPassword: true,
                                ),
                                Consumer<AuthViewModel>(
                                  builder:
                                      (context, value, child) => Column(
                                        children: [
                                          errorMessageWidget(
                                            value.confirmPasswordErrorMessage,
                                            context,
                                          ),
                                          errorMessageWidget(
                                            value.errorMessage,
                                            context,
                                          ),
                                        ],
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${AppLocalizations.of(context)!.already_have_an_account}\n',
                                              style: const TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.sign_in,
                                              style: TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer:
                                                  TapGestureRecognizer()
                                                    ..onTap = () {
                                                      context
                                                          .read<AuthViewModel>()
                                                          .clearErrors();
                                                      Navigator.of(
                                                        context,
                                                      ).pushReplacement(
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  SignInScreen(),
                                                        ),
                                                      );
                                                    },
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_forward,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          size: 35,
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            context
                                                .read<AuthViewModel>()
                                                .clearErrors();
                                            isLoading = true;
                                          });

                                          String email =
                                              emailController.text.trim();
                                          String password =
                                              passwordController.text.trim();
                                          String confirmPassword =
                                              confirmPasswordController.text
                                                  .trim();

                                          if (await Provider.of<AuthViewModel>(
                                            context,
                                            listen: false,
                                          ).register(
                                            email,
                                            password,
                                            confirmPassword,
                                          )) {
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
