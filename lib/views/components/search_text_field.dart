import 'package:flutter/material.dart';

class SearchByNameField extends StatelessWidget {
  final TextEditingController controller;
  final double textScale;
  final String hintText;
  final Color primaryColor;
  final void Function(String)? onSubmitted;

  const SearchByNameField({
    super.key,
    required this.controller,
    required this.textScale,
    required this.hintText,
    required this.primaryColor,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontFamily: 'Mplus1p',
          fontSize: 16 * textScale,
          fontWeight: FontWeight.w300,
          color: primaryColor,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),

          // left search icon with vertical divider
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (onSubmitted != null) {
                      onSubmitted!(controller.text);
                    }
                  },
                  child: Icon(
                    Icons.search,
                    color: primaryColor,
                    size: 28 * textScale,
                  ),
                ),
                const SizedBox(width: 6),
                Container(width: 2, height: 32, color: primaryColor),
              ],
            ),
          ),

          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Mplus1p',
            fontSize: 16 * textScale,
            fontWeight: FontWeight.w300,
            color: primaryColor,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: primaryColor, width: 3),
          ),
        ),
      ),
    );
  }
}
