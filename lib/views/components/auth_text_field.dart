import 'package:flutter/material.dart';
import 'package:randki/l10n/app_localizations.dart';

/// A custom text field widget for authentication forms, 
/// supporting both email and password input with error handling.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool isPassword;
  final bool isResetPassword;
  final String? errorMessage;
  const AuthTextField({
    super.key,
    required this.controller,
    this.isPassword = true,
    this.isResetPassword = false,
    this.errorMessage,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool isObscure;

  @override
  void initState() {
    isObscure = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        if(widget.isResetPassword && widget.isPassword) 
          Text(
             AppLocalizations.of(context)!.repeat_your_password,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
            ),
          ),
        if((!widget.isResetPassword && widget.isPassword) || (!widget.isResetPassword && !widget.isPassword)) 
          Text(
            widget.isPassword ? AppLocalizations.of(context)!.password : AppLocalizations.of(context)!.email,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
            ),
          ),
        SizedBox(
          height: 44,
          width: 289,
          child: TextField(
            obscureText: isObscure,
            controller: widget.controller,
            keyboardType:
                widget.isPassword
                    ? TextInputType.visiblePassword
                    : TextInputType.emailAddress,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              // Ikona przed tekstem
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8, right: 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isPassword ? Icons.lock_outline : Icons.email_outlined,
                      color:widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 2,
                      height: 32,
                      color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
                    ),
                  ],
                ),
              ),
              hintText: widget.isPassword ? "•••••" : AppLocalizations.of(context)!.email_hint_text,
              hintStyle: TextStyle(
                fontFamily: 'Mplus1p',
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
              ),
              // Ikonka do pokazywania hasła
              suffixIcon:
                  widget.isPassword
                      ? IconButton(
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                        icon: Icon(
                          isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
                          size: 28,
                        ),
                      )
                      : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: widget.errorMessage == null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error, 
                  width: 3,
                ),
              ),
            ),
          ),
        ),
      ]
    );
  }
}
