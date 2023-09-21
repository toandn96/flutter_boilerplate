import 'dart:developer';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
// import 'package:boilerplate/core/widgets/app_icon_widget.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/login/widgets/login_forgot_button.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/service_locator.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Field controllers
  TextEditingController userEmailController =
      TextEditingController(text: "toandn96@gmail.com");
  TextEditingController passwordController =
      TextEditingController(text: "Dnt@2605");

  // Stores
  final ThemeStore themeStore = getIt<ThemeStore>();
  final FormStore formStore = getIt<FormStore>();
  final UserStore userStore = getIt<UserStore>();

  // Focus node
  late FocusNode passwordFocusNode;

  // Override initState method
  @override
  void initState() {
    super.initState();
    passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: buildBody(),
    );
  }

  /**
  * Body method
  */
  Widget buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: buildLeftSide(),
                    ),
                    Expanded(
                      flex: 1,
                      child: buildRightSide(),
                    ),
                  ],
                )
              : Center(child: buildRightSide()),
          Observer(
            builder: (context) {
              return userStore.success
                  ? navigate(context)
                  : showErrorMessage(formStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: userStore.isLoading,
                child: CustomProgressIndicatorWidget(),
              );
            },
          )
        ],
      ),
    );
  }

/**
 * Left side widget
 */
  Widget buildLeftSide() {
    return SizedBox.expand(
      child: Image.asset(
        Assets.carBackground,
        fit: BoxFit.cover,
      ),
    );
  }

/**
 * Main widget
 */
  Widget buildRightSide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('app_name').toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Colors.orangeAccent),
            ),
            // AppIconWidget(image: 'assets/icons/ic_appicon.png'),
            SizedBox(height: 50.0),
            buildUserIdField(),
            buildPasswordField(),
            LoginForgotButton(),
            buildSignInButton()
          ],
        ),
      ),
    );
  }

  /**
   * Build the user name field
   */
  Widget buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context).translate('login_et_user_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          iconColor: themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            formStore.setUserId(userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },
          errorText: formStore.formErrorStore.userEmail,
        );
      },
    );
  }

  /**
   * Build the password field
   */
  Widget buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint:
              AppLocalizations.of(context).translate('login_et_user_password'),
          isObscure: true,
          padding: EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: passwordController,
          focusNode: passwordFocusNode,
          errorText: formStore.formErrorStore.password,
          onChanged: (value) {
            formStore.setPassword(passwordController.text);
          },
        );
      },
    );
  }

  /**
   * Build the SignIn button
   * 
   */
  Widget buildSignInButton() {
    return RoundedButtonWidget(
      buttonText: AppLocalizations.of(context).translate('login_btn_sign_in'),
      buttonColor: Colors.orangeAccent,
      textColor: Colors.white,
      onPressed: () async {
        if (formStore.canLogin) {
          DeviceUtils.hideKeyboard(context);
          userStore.login(userEmailController.text, passwordController.text);
        } else {
          showErrorMessage('Please fill in all fields');
        }
      },
    );
  }

  /**
   * Navigate to Home screen
   */
  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(Duration(milliseconds: 10), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
    });

    return Container();
  }

  /**
   * General Methods
   */
  showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return SizedBox.shrink();
  }

  /**
   * Dispose widgets
   */
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    userEmailController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }
}
