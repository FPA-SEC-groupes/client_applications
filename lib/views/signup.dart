import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way_client/views/login.dart';
import 'package:hello_way_client/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/network_service.dart';
import '../utils/routes.dart';
import '../view_models/signup_view_model.dart';
import '../widgets/button.dart';
import '../widgets/input_form.dart';
import '../widgets/input_form_password.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final SignupViewModel _signUpViewModel = SignupViewModel();
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController, _emailController, _phoneNumberController, _passwordController, _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: Toolbar(title: AppLocalizations.of(context)!.signUp),
      body: networkStatus == NetworkStatus.Online
          ? Center(
          child: Form(
            key: _signupFormKey,
            child: SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(context)!.createAccount,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(children: [
                      InputForm(
                        hint: AppLocalizations.of(context)!.username,
                        controller: _usernameController,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        contentPadding: const EdgeInsets.all(10),
                        validator: MultiValidator([
                          RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      InputForm(
                        hint: AppLocalizations.of(context)!.email,
                        controller: _emailController,
                        prefixIcon: const Icon(Icons.email_outlined),
                        contentPadding: const EdgeInsets.all(10),
                        validator: MultiValidator([
                          RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                          EmailValidator(errorText: AppLocalizations.of(context)!.invalidEmail)
                        ]),
                      ),
                      const SizedBox(height: 15),
                      InputForm(
                        hint: AppLocalizations.of(context)!.phoneNumber,
                        controller: _phoneNumberController,
                        prefixIcon: const Icon(Icons.phone),
                        contentPadding: const EdgeInsets.all(10),
                        validator: MultiValidator([
                          RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                          LengthRangeValidator(min: 8, max: 12, errorText: AppLocalizations.of(context)!.phoneLengthError),
                          PatternValidator(r'(^(?:\+216)?[0-9]{8}$)', errorText: AppLocalizations.of(context)!.phonePatternError),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      InputFormPassword(
                        controller: _passwordController,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        hint: AppLocalizations.of(context)!.password,
                        validator: MultiValidator([
                          RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                          MinLengthValidator(8, errorText: AppLocalizations.of(context)!.passwordLengthRequirement),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      InputFormPassword(
                        controller: _confirmPasswordController,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        hint: AppLocalizations.of(context)!.confirmationPassword,
                        validator: MultiValidator([
                          RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      Button(
                        text: AppLocalizations.of(context)!.signUp,
                        onPressed: () async {
                          if (_signupFormKey.currentState!.validate()) {
                            _signupFormKey.currentState!.save();
                            final updatedUser = User(
                              username: _usernameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            _signUpViewModel.signup(context, updatedUser).then((_) {
                              // Handle successful signup
                              Navigator.of(context).pop(); // Optionally navigate back or to another screen
                            }).catchError((error) {
                              print('Signup error: $error');
                              // Handle errors like showing an error message
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.oldAccount,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  Login(
                                        previousPage:'signup'
                                    ),
                                  ),
                                );
                                // Navigator.pushNamed(context, loginRoute);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(color: Colors.orange, fontSize: 16), // Directly using Colors.orange
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ))
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.network_check, size: 150, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.noInternet,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(
                AppLocalizations.of(context)!.checkYourInternet,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () {
                  setState(() {
                    // This could be used to re-attempt a network connection or refresh the page
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
