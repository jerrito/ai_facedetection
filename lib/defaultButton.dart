import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
 final Color?  backgroundColor;
 final Widget? child;
final void Function()? onPressed;
  const DefaultButton({Key? key, this.child, this.onPressed, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:double.infinity,//height: 30,
      child: ElevatedButton(onPressed: onPressed,
          style:ElevatedButton.styleFrom(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 10,bottom:16),
            shape:const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            backgroundColor: backgroundColor,
            foregroundColor: Colors.black,
          ),
          child: child),
    );
  }
}
