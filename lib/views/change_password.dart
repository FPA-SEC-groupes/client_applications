import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import '../Widgets/button.dart';
import '../Widgets/input_form_password.dart';
import '../request/reset_password_request.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../utils/const.dart';
import '../utils/secure_storage.dart';
import '../view_models/change_password_view_model.dart';
import '../widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late final ChangePasswordViewModel _changePasswordViewModel;
  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();
  final SecureStorage secureStorage = SecureStorage();
  late final TextEditingController _currentPasswordController,
      _newPasswordController,
      _confirmNewPasswordController;
 String? password;
  @override
  void initState() {
    _changePasswordViewModel = ChangePasswordViewModel(context);
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar:   Toolbar(title:AppLocalizations.of(context)!.changePassword),
      backgroundColor: Colors.white,
      body: networkStatus == NetworkStatus.Online
          ?Center(
          child: Form(
        key: _changePasswordFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/change_password.png",
                width: 150,
                height: 150,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(children: [
                  const SizedBox(
                    height: 20,
                  ),
                  InputFormPassword(
                    hint: AppLocalizations.of(context)!.oldPassword,
                    controller: _currentPasswordController,
                    contentPadding: const EdgeInsets.all(10),
                    validator: MultiValidator([

                      RequiredValidator(errorText:  AppLocalizations.of(context)!.inputRequiredError),


                    ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputFormPassword(
                    hint: AppLocalizations.of(context)!.newPassword,
                    controller: _newPasswordController,
                    onChanged: (val) => password = val!,
                    contentPadding: const EdgeInsets.all(10),
                    validator: MultiValidator([

                      RequiredValidator(errorText:  AppLocalizations.of(context)!.inputRequiredError),

                      MinLengthValidator(
                        8,
                        errorText:
                        AppLocalizations.of(context)!.passwordLengthRequirement,
                      ),



                    ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputFormPassword(
                    hint: AppLocalizations.of(context)!.confirmPassword,
                    controller: _confirmNewPasswordController,
                    contentPadding: const EdgeInsets.all(10),
                    validator:
                        (val) {
                      if (val == null || val.isEmpty) {
                        return  AppLocalizations.of(context)!.inputRequiredError;
                      } else if (val != password) {
                        return AppLocalizations.of(context)!.passwordsDoNotMatch;
                      }
                      return null;
                    },

                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Button(
                    text: AppLocalizations.of(context)!.confirm,
                    onPressed: () async {
                      if (_changePasswordFormKey.currentState!.validate()) {
                        _changePasswordFormKey.currentState!.save();
                        final emailUser = await secureStorage.readData(email);

                        final resetPasswordRequest = ResetPasswordRequest(
                          email: emailUser!,
                          newPassword: _newPasswordController.text.trim(),
                        );

                        _changePasswordViewModel.changePassword(context, resetPasswordRequest).then((_) {
                          Navigator.of(context).pop();
                        }).catchError((error) {
                          print(error);
                        });

                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ]),
              ),
            ],
          ),
        ),
      )):Center(
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
              const SizedBox(height: 10,),
              MaterialButton(
                color: orange,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed:(){
                  setState(() {

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
