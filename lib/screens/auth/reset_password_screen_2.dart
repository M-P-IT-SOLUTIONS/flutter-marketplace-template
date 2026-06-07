import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/view_models/auth_view_model.dart';
import 'package:flutter_marketplace_template/views/components/auth_text_field.dart';
import 'package:flutter_marketplace_template/views/components/error_message_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen for resetting password after user clicks the link in email,
/// accessed by link with code query parameter,
/// which is used to exchange for session and allow user to set new password
class ResetPasswordScreen2 extends StatefulWidget {
  const ResetPasswordScreen2({super.key});

  @override
  State<ResetPasswordScreen2> createState() => _ResetPasswordScreen2State();
}

class _ResetPasswordScreen2State extends State<ResetPasswordScreen2> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initRecoverySession();
  }

  Future<void> _initRecoverySession() async {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];

    if (code != null) {
      try {
        await Supabase.instance.client.auth.exchangeCodeForSession(code);
      } catch (e) {
        Provider.of<AuthViewModel>(context, listen: false).errorMessage =
            AppLocalizations.of(context)!.reset_link_expired;
      }
    }
  }

  Future<void> _submit() async {
    context.read<AuthViewModel>().clearErrors();

    final password = _passwordCtrl.text.trim();
    final confirmPassword = _confirmCtrl.text.trim();

    if (!validatePasswords(password, confirmPassword)) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordCtrl.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.password_changed)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      context.read<AuthViewModel>().errorMessage = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  bool validatePasswords(String? password, String? confirmPassword) {
    if (password == null || password.isEmpty) {
      context.read<AuthViewModel>().passwordErrorMessage =
          AppLocalizations.of(context)!.empty_password;
      return false;
    }
    if (!context.read<AuthViewModel>().validatePassword(password)) {
      return false;
    }
    if (confirmPassword == null || confirmPassword.isEmpty) {
      context.read<AuthViewModel>().confirmPasswordErrorMessage =
          AppLocalizations.of(context)!.empty_password;
      return false;
    }

    if (!context.read<AuthViewModel>().validatePasswordsMatch(
      password,
      confirmPassword,
    )) {
      return false;
    }
    return true;
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
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AuthTextField(
                  controller: _passwordCtrl,
                  isPassword: true,
                  isResetPassword: false,
                  errorMessage:
                      context.watch<AuthViewModel>().passwordErrorMessage,
                ),
                Consumer<AuthViewModel>(
                  builder:
                      (context, value, child) => errorMessageWidget(
                        value.passwordErrorMessage,
                        context,
                      ),
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _confirmCtrl,
                  isPassword: true,
                  isResetPassword: true,
                  errorMessage:
                      context
                          .watch<AuthViewModel>()
                          .confirmPasswordErrorMessage,
                ),
                Consumer<AuthViewModel>(
                  builder:
                      (context, value, child) => Column(
                        children: [
                          errorMessageWidget(
                            value.confirmPasswordErrorMessage,
                            context,
                          ),
                          errorMessageWidget(value.errorMessage, context),
                        ],
                      ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child:
                      _loading
                          ? const CircularProgressIndicator()
                          : Text(AppLocalizations.of(context)!.change_password),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
