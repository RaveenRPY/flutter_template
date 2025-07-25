import 'package:AventaPOS/core/services/dependency_injection.dart';
import 'package:AventaPOS/features/presentation/bloc/base_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_event.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_state.dart';
import 'package:AventaPOS/features/presentation/bloc/sale/sale_bloc.dart';
import 'package:AventaPOS/features/presentation/views/base_view.dart';
import 'package:AventaPOS/features/presentation/views/login/widgets/opening_balance.dart';
import 'package:AventaPOS/features/presentation/widgets/app_dialog_box.dart';
import 'package:AventaPOS/features/presentation/widgets/app_main_button.dart';
import 'package:AventaPOS/utils/app_colors.dart';
import 'package:AventaPOS/utils/app_images.dart';
import 'package:AventaPOS/utils/app_stylings.dart';
import 'package:AventaPOS/utils/navigation_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/zynolo_form_field.dart';

class LoginView extends BaseView {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends BaseViewState<LoginView> {
  final LoginBloc _loginBloc = inject<LoginBloc>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _usernameKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  bool isUsernameValidated = false;
  bool isPasswordValidated = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget buildView(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => _loginBloc,
      child: BlocListener<LoginBloc, BaseState<LoginState>>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            FocusManager.instance.primaryFocus?.unfocus();
            // Navigator.pushReplacementNamed(context, Routes.kSaleView);
            if (!(state.isOpening ?? false)) {
              OpeningBalance.show(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.kSaleView,
                (route) => false,
              );
            }
          } else if (state is LoginFailedState) {
            FocusManager.instance.primaryFocus?.unfocus();
            AppDialogBox.show(
              context,
              title: 'Oops..!',
              message: state.errorMsg,
              image: AppImages.failedDialog,
              isTwoButton: false,
              positiveButtonTap: () {},
              positiveButtonText: 'Try Again',
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: Padding(
            padding: EdgeInsets.all(2.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: AppColors.darkGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(40)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        AppImages.loginBg,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "AVENTA",
                                    style: AppStyling.semi25Black.copyWith(
                                        color: AppColors.primaryColor,
                                        fontSize: 22.sp),
                                  ),
                                  Text(
                                    "POS",
                                    style: AppStyling.semi25Black.copyWith(
                                        color: AppColors.darkBlue,
                                        fontSize: 22.sp),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.sp,
                              ),
                              Text(
                                "Welcome Back",
                                style: AppStyling.medium12Black.copyWith(
                                    fontSize: 14.5.sp,
                                    color: AppColors.blackColor),
                              ),
                              SizedBox(
                                height: 5.sp,
                              ),
                              Text(
                                "Please enter your details to sign in",
                                style: AppStyling.regular12Grey.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.darkGrey.withOpacity(0.7)),
                              ),
                              SizedBox(
                                height: 20.sp,
                              ),
                              SizedBox(
                                width: 30.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Username",
                                      style: AppStyling.medium12Black.copyWith(
                                          color: AppColors.darkGrey,
                                          fontSize: 11.sp),
                                    ),
                                    SizedBox(height: 8.sp),
                                    Form(
                                      key: _usernameKey,
                                      child: AventaFormField(
                                        focusNode: _focusNode,
                                        controller: _usernameController,
                                        hintText: "Enter your Username",
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Icon(
                                            Icons.alternate_email_rounded,
                                            size: 23,
                                          ),
                                        ),
                                        prefixIconColor: AppColors.primaryColor,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            setState(() {
                                              isUsernameValidated = false;
                                            });
                                            return 'Username can\'t be empty';
                                          } else {
                                            setState(() {
                                              isUsernameValidated = true;
                                            });
                                          }

                                          return null;
                                        },
                                        onChanged: (value) {
                                          _usernameKey.currentState?.validate();
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 14.sp),
                                    Text(
                                      "Password",
                                      style: AppStyling.medium12Black.copyWith(
                                          color: AppColors.darkGrey,
                                          fontSize: 11.sp),
                                    ),
                                    SizedBox(height: 7.sp),
                                    Form(
                                      key: _passwordKey,
                                      // autovalidateMode:
                                      //     AutovalidateMode.onUserInteraction,
                                      child: AventaFormField(
                                        controller: _passwordController,
                                        hintText: "Enter your Password",
                                        isObsecure: true,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Icon(
                                            Icons.lock_outline_rounded,
                                            size: 23,
                                          ),
                                        ),
                                        prefixIconColor: AppColors.primaryColor,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            setState(() {
                                              isPasswordValidated = false;
                                            });
                                            return 'Password can\'t be empty';
                                          } else {
                                            setState(() {
                                              isPasswordValidated = true;
                                            });
                                          }
                                          return null;
                                        },
                                        onCompleted: () {
                                          FocusScope.of(context).unfocus();
                                          _usernameKey.currentState?.validate();
                                          _passwordKey.currentState?.validate();

                                          if (isPasswordValidated &&
                                              isUsernameValidated) {
                                            _loginBloc.add(CashierLoginEvent(
                                              username: _usernameController.text
                                                  .trim(),
                                              password: _passwordController.text
                                                  .trim(),
                                            ));
                                          }
                                        },
                                        onChanged: (value) {
                                          _passwordKey.currentState?.validate();
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20.sp),
                                    AppMainButton(
                                      title: "Login",
                                      titleStyle: AppStyling.medium14Black
                                          .copyWith(
                                              color: AppColors.whiteColor,
                                              fontSize: 12.sp,
                                              height: 1),
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        _usernameKey.currentState?.validate();
                                        _passwordKey.currentState?.validate();

                                        if (isPasswordValidated &&
                                            isUsernameValidated) {
                                          _loginBloc.add(CashierLoginEvent(
                                            username:
                                                _usernameController.text.trim(),
                                            password:
                                                _passwordController.text.trim(),
                                          ));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "© 2025 AventaPOS. All Rights Reserved.",
                          style: AppStyling.regular12Grey,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  List<BaseBloc<BaseEvent, BaseState>> getBlocs() {
    return [_loginBloc];
  }
}
