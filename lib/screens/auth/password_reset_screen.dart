import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/views/components/auth_text_field.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';

/// Screen for resetting password, consists of 3 steps: entering email, entering code from email, setting new password
/// Diferent look for password reset screen for replacing if you like it more
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

enum ResetStep {
  email,
  code,
  password
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  ResetStep currentStep = ResetStep.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const CustomAppBar(
        showTitle: false,
        showMenu: false,
        showChat: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 28,
                right: 28,
                child: Container(
                  //height: 240,
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
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
                        padding: const EdgeInsets.only(left: 9),
                        child: Text(
                          AppLocalizations.of(context)!.reset_your_password,
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 24,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const Divider(
                        height: 5,
                        thickness: 0.5,
                        color: Color.fromRGBO(195, 196, 215, 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 9, right: 9),
                        child: 
                          currentStep == ResetStep.email ?
                          _emailStep(context, emailController)
                          : (currentStep == ResetStep.code ? 
                            _codeStep(context, emailController.text) 
                            : _passwordStep(context, emailController.text, passwordController, repeatPasswordController)),
                      ),
                      const SizedBox(height: 7),
                      if(currentStep != ResetStep.email)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 35,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if(currentStep == ResetStep.code) {
                                      currentStep = ResetStep.email;
                                    }
                                    else if(currentStep == ResetStep.password) {
                                      currentStep = ResetStep.code;
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: 35,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  //TODO: checking data validity and proceeding
                                  setState(() {
                                    if(currentStep == ResetStep.email) {
                                      currentStep = ResetStep.code;
                                    }
                                    else if(currentStep == ResetStep.code) {
                                      currentStep = ResetStep.password;
                                    }
                                    else {
                                      Navigator.of(context).pop();
                                    }
                                  });
                                },
                              ),
                          ]
                        ),
                        if(currentStep == ResetStep.email)
                           Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: 35,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  //TODO: checking data validity and proceeding
                                  setState(() {
                                    if(currentStep == ResetStep.email) {
                                      currentStep = ResetStep.code;
                                    }
                                    else if(currentStep == ResetStep.code) {
                                      currentStep = ResetStep.password;
                                    }
                                    else {
                                      Navigator.of(context).pop();
                                    }
                                  });
                                },
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


Widget _emailStep(BuildContext context, TextEditingController emailController,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 14),
      Text(
        AppLocalizations.of(context)!.enter_your_email,
        style: TextStyle(
          fontFamily: 'Mplus1p',
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color:
            Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 12),
      AuthTextField(
        controller: emailController,
        isPassword: false,
        isResetPassword: true,
        //errorMessage: "",
      ),
    ],
  );
}

Widget _passwordStep(BuildContext context, String email, TextEditingController passwordController, TextEditingController repeatPasswordController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 14),
      Center(
        child: Text(
          AppLocalizations.of(context)!.set_a_new_password,
          style: TextStyle(
            fontFamily: 'Mplus1p',
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color:
              Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Mplus1p',
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      const SizedBox(height: 13),
      Center(
        child: 
          AuthTextField(
            controller: passwordController,
            isPassword: true,
            //errorMessage: "fail",
          )
      ),
      const SizedBox(height: 9),
      Center(
        child: 
          AuthTextField(
            controller: repeatPasswordController,
            isPassword: true,
            isResetPassword: true,
            //errorMessage: "fail",
          )
      ),
    ],
  );
}

Widget _codeStep(BuildContext context, String email) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 14),
      Text(
        AppLocalizations.of(context)!.enter_the_code ,
        style: TextStyle(
          fontFamily: 'Mplus1p',
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color:
            Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Mplus1p',
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      const SizedBox(height: 13),
      Center(
        child: AuthCodeField(
            length: 6,
            //errorMessage: "fail",
          ),
      ),
    ],
  );
}

class AuthCodeField extends StatefulWidget {
  final int length;
  final String? errorMessage;
  final void Function(String code)? onCompleted;

  const AuthCodeField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.errorMessage,
  });

  @override
  State<AuthCodeField> createState() => _AuthCodeFieldState();
}

class _AuthCodeFieldState extends State<AuthCodeField> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers =
        List.generate(widget.length, (_) => TextEditingController());
    focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Row(
        children: [
          _buildBox(context, index),
          if (index != widget.length - 1)
            const SizedBox(width: 6), 
        ],
      );
      }),
    );
  }

  Widget _buildBox(BuildContext context, int index) {
    return SizedBox(
      width: 36,
      height: 44,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center, 
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: TextStyle(
          fontFamily: 'Mplus1p',
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          enabledBorder: _border(context),
          focusedBorder: _focusedBorder(context),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < widget.length - 1) {
              FocusScope.of(context)
                  .requestFocus(focusNodes[index + 1]);
            }
          } else {
            if (index > 0) {
              FocusScope.of(context)
                  .requestFocus(focusNodes[index - 1]);
            }
          }

          _checkCompleted();
        },
      ),
    );
  }

  void _checkCompleted() {
    final code = controllers.map((c) => c.text).join();
    if (code.length == widget.length &&
        !code.contains('')) {
      widget.onCompleted?.call(code);
    }
  }

  OutlineInputBorder _border(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
        width: 2
      ),
    );
  }

  OutlineInputBorder _focusedBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
        width: 3,
      ),
    );
  }
}