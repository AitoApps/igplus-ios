import 'package:flutter/material.dart';
import 'package:igshark/app/bloc/app_bloc.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

logoutAlert(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel", style: TextStyle(color: ColorsManager.primaryColor)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Logout", style: TextStyle(color: ColorsManager.primaryColor)),
    onPressed: () {
      context.read<AppBloc>().add(AppLogoutRequested());
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: ColorsManager.cardBack,
    title: const Text("Are you sure you want to log out?", style: TextStyle(color: ColorsManager.textColor)),
    content: const Text("When you log out, all your data will be deleted permanently.",
        style: TextStyle(color: ColorsManager.textColor)),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
