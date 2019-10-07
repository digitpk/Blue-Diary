
import 'package:flutter/material.dart';
import 'package:todo_app/AppColors.dart';
import 'package:todo_app/Localization.dart';
import 'package:todo_app/domain/usecase/SettingsUsecases.dart';
import 'package:todo_app/presentation/App.dart';
import 'package:todo_app/presentation/createpassword/CreatePasswordScreen.dart';

class SettingsBloc {
  final SettingsUsecases _usecases = dependencies.settingsUsecases;

  Future<void> onDefaultLockChanged(BuildContext context, ScaffoldState scaffoldState) async {
    final isDefaultLocked = await _usecases.getDefaultLocked();
    final userPassword = await _usecases.getUserPassword();

    if (isDefaultLocked && userPassword.isEmpty) {
      _usecases.setDefaultLocked(false);
      _showCreatePasswordDialog(context, scaffoldState);
    }
  }

  Future<void> _showCreatePasswordDialog(BuildContext context, ScaffoldState scaffoldState) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).createPassword,
            style: TextStyle(
              color: AppColors.TEXT_BLACK,
              fontSize: 20,
            ),
          ),
          content: Text(
            AppLocalizations.of(context).createPasswordBody,
            style: TextStyle(
              color: AppColors.TEXT_BLACK_LIGHT,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(
                  color: AppColors.TEXT_BLACK,
                  fontSize: 14,
                ),
              ),
              onPressed: () => _onCreatePasswordCancelClicked(context),
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).ok,
                style: TextStyle(
                  color: AppColors.PRIMARY,
                  fontSize: 14,
                ),
              ),
              onPressed: () => _onCreatePasswordOkClicked(context, scaffoldState),
            )
          ],
        );
      },
    );
  }

  void _onCreatePasswordCancelClicked(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onCreatePasswordOkClicked(BuildContext context, ScaffoldState scaffoldState) async {
    Navigator.pop(context);
    final successMsg = AppLocalizations.of(context).createPasswordSuccess;
    final failMsg = AppLocalizations.of(context).createPasswordFail;
    await scaffoldState.showBottomSheet((context) => CreatePasswordScreen()).closed;
    final isPasswordSaved = await _usecases.getUserPassword().then((s) => s.length > 0);
    if (isPasswordSaved) {
      scaffoldState.showSnackBar(SnackBar(
        content: Text(successMsg),
        duration: Duration(seconds: 2),
      ));
    } else {
      scaffoldState.showSnackBar(SnackBar(
        content: Text(failMsg),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void onSendTempPasswordClicked() {

  }

  void onResetPasswordClicked() {

  }

  void dispose() {

  }
}
