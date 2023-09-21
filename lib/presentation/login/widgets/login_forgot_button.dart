import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';

/**
 * Build the forgot password button
*/
class LoginForgotButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.centerRight,
      child: MaterialButton(
        padding: EdgeInsets.all(0.0),
        child: Text(
          AppLocalizations.of(context).translate('login_btn_forgot_password'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.orangeAccent, fontStyle: FontStyle.italic),
        ),
        onPressed: () {
          print('Press forgot button');
        },
      ),
    );
  }
}
