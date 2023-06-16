import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AISnackBar {
  AISnackBar(BuildContext context) {
    fToast.init(context);
    _context = context;
  }

  FToast fToast = FToast();
  late BuildContext _context;

  displaySnackBar({required String message, Color? backgroundColor}) {
    Widget toast = Container(
      padding: const EdgeInsets.fromLTRB(15,10,15,10),
      width: MediaQuery.of(_context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor ?? Colors.amberAccent,
      ),
      child: SizedBox(
        width: MediaQuery.of(_context).size.width,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );

    fToast.showToast(
        child: toast,
        toastDuration: const Duration(seconds: 5),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 100.0,
            left: 0,
          );
        });
  }
}
