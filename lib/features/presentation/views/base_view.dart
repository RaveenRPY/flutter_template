import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../bloc/base_bloc.dart';
import '../widgets/custom_dialog_box.dart';

abstract class BaseView extends StatefulWidget {
  const BaseView({super.key});
}

abstract class BaseViewState<Page extends BaseView> extends State<Page> {
  Widget buildView(BuildContext context);

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
                            // _localDatasource.clearAccessToken();
                          });
                          // Navigator.pushNamedAndRemoveUntil(
                          //   context,
                          //   Routes.kLoginView,
                          //   (route) => false,
                          // );
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
                  filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
                  child: Container(
                    alignment: FractionalOffset.center,
                    child: Wrap(
                      children: [
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 5,
                          ),
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
