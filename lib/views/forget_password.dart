import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way_client/utils/routes.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';
import '../widgets/button.dart';
import '../widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../view_models/forget_password_view_model.dart';
import '../utils/secure_storage.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  late ForgetPasswordViewModel _forgetPasswordViewModel;
  final GlobalKey<FormState> _forgetPasswordKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _forgetPasswordViewModel = ForgetPasswordViewModel(context);
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.forgotPassword),
        backgroundColor: Colors.orange,
        actions: [],
      ),
      body: networkStatus == NetworkStatus.Online
          ? Center(
        child: Form(
          key: _forgetPasswordKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo widget
                Container(
                  height: 100,
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 30.0, // Increase top margin to push the content down
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain, // This will keep the aspect ratio of the image
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.passwordResetEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: InputForm(
                    hint: AppLocalizations.of(context)!.email,
                    controller: _emailController,
                    contentPadding: const EdgeInsets.all(10),
                    validator: MultiValidator([
                      RequiredValidator(
                          errorText: AppLocalizations.of(context)!.inputRequiredError),
                      EmailValidator(
                          errorText: AppLocalizations.of(context)!.invalidEmail),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                Button(
                  text: AppLocalizations.of(context)!.send,
                  onPressed: () async {
                    if (_forgetPasswordKey.currentState!.validate()) {
                      _forgetPasswordKey.currentState!.save();
                      final email = _emailController.text.trim();
                      _forgetPasswordViewModel.resetPassword(email).then((message) async {
                        if (message == "Password reset successfully. Please check your email for the new password.") {
                          Navigator.pushNamed(context, loginRoute);
                        } else if (message == "Error: User not found with the provided email.") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(AppLocalizations.of(context)!.emailNotAssociated),
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }).catchError((error) {
                        print(error);
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-space');
                  },
                  child: Text('Go to Add Space Page'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.network_check,
                size: 150,
                color: gray,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.noInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              Text(
                AppLocalizations.of(context)!.checkYourInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              MaterialButton(
                color: orange,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () {
                  setState(() {});
                },
                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
