import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/core/auth_result.dart';
import 'package:flutter_marketplace_template/services/auth_service.dart';
import 'package:flutter_marketplace_template/view_models/auth_view_model.dart';
import 'package:flutter_marketplace_template/views/components/auth_text_field.dart';
import 'package:flutter_marketplace_template/views/components/error_message_widget.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';

/// Screen for sending reset password email, where user enters email and receives link to reset password
class SendResetPasswordEmailScreen extends StatefulWidget {
  const SendResetPasswordEmailScreen({super.key});

  @override
  State<SendResetPasswordEmailScreen> createState() =>
      _SendResetPasswordEmailScreenState();
}

class _SendResetPasswordEmailScreenState
    extends State<SendResetPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (!context.read<AuthViewModel>().validateEmail(email)) {
      return;
    }
    setState(() {
      context.read<AuthViewModel>().clearErrors();
    });
    final res = await context.read<IAuthService>().resetPassword(email);
    if (res is AuthSuccess) {
      context.read<AuthViewModel>().clearErrors();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.password_reset_link_sent,
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } else if (res is AuthError) {
      setState(() {
        context.read<AuthViewModel>().errorMessage = res.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showTitle: false,
        showMenu: false,
        showChat: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AuthTextField(
                controller: _emailController,
                isPassword: false,
                errorMessage: context.watch<AuthViewModel>().emailErrorMessage,
              ),
              Consumer<AuthViewModel>(
                builder:
                    (context, value, child) => Column(
                      children: [
                        errorMessageWidget(value.emailErrorMessage, context),
                        errorMessageWidget(value.errorMessage, context),
                      ],
                    ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleResetPassword,
                child: Text(AppLocalizations.of(context)!.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
