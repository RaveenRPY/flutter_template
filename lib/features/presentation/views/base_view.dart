import 'dart:ui';
import 'package:AventaPOS/core/services/dependency_injection.dart';
import 'package:AventaPOS/features/data/datasources/local_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/navigation_routes.dart';
import '../bloc/base_bloc.dart';
import '../widgets/custom_dialog_box.dart';

abstract class BaseView extends StatefulWidget {
  const BaseView({super.key});
}

abstract class BaseViewState<Page extends BaseView> extends State<Page> {
  Widget buildView(BuildContext context);

  final LocalDatasource _localDatasource = inject<LocalDatasource>();

  List<BaseBloc> getBlocs();

  bool _isLoadingShow = false;

  @override
  Widget build(BuildContext context) {
    final List<BaseBloc> blocs = getBlocs();

    return Material(
      child: MultiBlocProvider(
        providers: blocs
            .map((bloc) => BlocProvider<BaseBloc>.value(value: bloc))
            .toList(),
        child: MultiBlocListener(
          listeners: blocs
              .map(
                (bloc) => BlocListener<BaseBloc, BaseState>(
                  bloc: bloc,
                  listener: (context, state) {
                    if (state is APILoadingState) {
                      showProgress();
                    } else {
                      hideProgress();
                    }
                    if (state is APIFailureState) {
                      hideProgress();
                      CustomDialogBox.show(
                        context,
                        title: 'Oops!',
                        message: state.error,
                        image: AppImages.failedDialog,
                        positiveButtonText: 'Close',
                        isTwoButton: false,
                        positiveButtonTap: () {},
                      );
                    } else if (state is TokenInvalidState) {
                      hideProgress();
                      CustomDialogBox.show(
                        context,
                        title: 'Oops!',
                        message: state.error,
                        image: AppImages.failedDialog,
                        positiveButtonText: 'Log Out',
                        isTwoButton: false,
                        positiveButtonTap: () {
                          setState(() {
                            _localDatasource.clearAccessToken();
                          });
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.kLoginView,
                            (route) => false,
                          );
                        },
                      );
                    }
                  },
                ),
              )
              .toList(),
          child: buildView(context),
        ),
      ),
    );
  }

  void showProgress() {
    if (!_isLoadingShow) {
      setState(() {
        _isLoadingShow = true;
      });
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.transparent,
        transitionBuilder: (context, a1, a2, widget) {
          return WillPopScope(
            child: Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                  child: Container(
                    alignment: FractionalOffset.center,
                    child: Wrap(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.whiteColor),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Lottie.asset(
                              AppImages.loadingAnimation,
                              frameRate: const FrameRate(90),
                            ),
                          ),
                          // child: Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: CircularProgressIndicator(
                          //     color: AppColors.primaryColor,
                          //     strokeWidth: 4,
                          //     trackGap: 5,
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            onWillPop: () async => false,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SizedBox.shrink();
        },
      );
    }
  }

  void hideProgress() {
    if (_isLoadingShow) {
      Navigator.pop(context);
      setState(() {
        _isLoadingShow = false;
      });
    }
  }
}
