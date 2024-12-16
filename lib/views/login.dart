import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way_client/models/space.dart';
import 'package:hello_way_client/navigations/bottom_navigation_bar_with_fab.dart';
import 'package:hello_way_client/res/app_colors.dart';
import 'package:hello_way_client/utils/routes.dart';
import 'package:hello_way_client/view_models/login_view_model.dart';
import 'package:hello_way_client/views/add_reservation.dart';
import 'package:hello_way_client/views/forget_password.dart';
import 'package:hello_way_client/views/signup.dart';
import 'package:hello_way_client/views/space.dart';
import 'package:hello_way_client/widgets/input_form_password.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';
import '../widgets/app_bar.dart';
import '../widgets/button.dart';
import '../widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  final String? previousPage;
  final Space? space;
  final int? nb;
  final bool? authentifiedUser;
  final int? index;

  const Login({this.previousPage, this.space,this.nb , this.authentifiedUser, this.index}) ;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginViewModel _loginViewModel = LoginViewModel();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController, _passwordController;
  late int? index;
  late String previousPage="";
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    // Retrieve arguments as a map
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      previousPage = (arguments['previousPage'] as String?)!;
      index = arguments['index'] as int?;
    } else {
      print('No arguments were provided.');
    }
    return WillPopScope(
        onWillPop: () async {
          if(previousPage=="notification"){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  BottomNavigationBarWithFAB(
                  index: 0,
                ),
              ),
            );
          } else if(previousPage=="setting") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BottomNavigationBarWithFAB(
                      index: 4,
                    ),
              ),
            );
          }else if (previousPage=="compte"){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  BottomNavigationBarWithFAB(
                  index: 0,
                ),
              ),
            );
            print("okkkkkkkkkkkkkkkkkkkkkk"+widget.previousPage!);
            // switch (widget.previousPage) {
            //   case 'signup':
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             SignUp(
            //             ),
            //       ),
            //     );
            //     break;
            //   case 'password':
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ForgetPassword(),
            //       ),
            //     );
            //     break;
            //   case 'space':
            //     print("okkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             DetailsSpace(
            //                 space: widget.space!,
            //                 nb: widget.nb,
            //                 authentifiedUser: widget.authentifiedUser
            //             ),
            //       ),
            //     );
            //     break;
            //   default:
            //     Navigator.pushReplacementNamed(
            //         context, bottomNavigationWithFABRoute, arguments: index);
            // }
          }
      return true;
    },
    child:Scaffold(
      appBar: Toolbar(title: AppLocalizations.of(context)!.login),
      body: networkStatus == NetworkStatus.Online
          ? Center(
        child: Form(
          key: _loginFormKey,
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
                const SizedBox(height: 20),
                InputForm(
                  hint: AppLocalizations.of(context)!.username,
                  controller: _usernameController,
                  prefixIcon: const Icon(Icons.person),
                  contentPadding: const EdgeInsets.all(10),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: AppLocalizations.of(context)!.inputRequiredError),
                  ]),
                ),
                const SizedBox(height: 20),
                InputFormPassword(
                  hint: AppLocalizations.of(context)!.password,
                  controller: _passwordController,
                  prefixIcon: const Icon(Icons.lock),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: AppLocalizations.of(context)!.inputRequiredError),
                  ]),
                  contentPadding: const EdgeInsets.all(10),
                ),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(AppLocalizations.of(context)!.forgotPassword),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, forgetPasswordRoute);
                  },
                ),
                Button(
                  text: AppLocalizations.of(context)!.login,
                  onPressed: () async {
                    if (_loginFormKey.currentState!.validate()) {
                      _loginFormKey.currentState!.save();
                      var username = _usernameController.text.trim().toString();
                      var password = _passwordController.text.trim().toString();
                      _loginViewModel.login(context, username, password).then((user) {
                        if (index != null) {
                          Navigator.pushReplacementNamed(context, bottomNavigationWithFABRoute, arguments: index);
                        } else if(widget.previousPage=="space"){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReservation(space: widget.space!),
                            ),
                          );
                        }
                        else {
                          Navigator.of(context).pop();
                        }
                      }).catchError((error) {
                        print(error);
                      });
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.newAccount),
                      const SizedBox(width: 5),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Text(
                            AppLocalizations.of(context)!.signUp,
                            style: const TextStyle(color: yellow),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, signUpRoute);
                        },
                      ),
                    ],
                  ),
                ),
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
              )
            ],
          ),
        ),
          )
            ),
    );
  }
}
