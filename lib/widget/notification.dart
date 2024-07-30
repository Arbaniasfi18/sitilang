import 'package:flutter/material.dart';
import 'package:sitilang_1_0_0/properties/spacing.dart';
import 'package:sitilang_1_0_0/properties/text.dart';
import 'package:sitilang_1_0_0/screen/home.dart';


warnNotif(context, 
{required Widget content}) => 
showDialog(
  context: context, 
  builder: (context) {
  return AlertDialog(
    title: Text("Peringatan"),
    content: content,
    actions: [
      TextButton(
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }, 
        child: Text("Okay"),
      )
    ],
  );
});

showSomethin(context, 
{required Widget content}) => 
showDialog(
  context: context, 
  builder: (context) {
  return AlertDialog(
    content: content,
  );
});

loadingWidget(context, {
  String? message
  }) => 
showDialog(
  context: context, 
  barrierDismissible: false,
  builder: (context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.grey,
        ),
        child: message != null 
        ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
            ),
            HeightSpacing(20),
            DefaultTextStyle(
              style: loadingTxt, 
              child: Text(message),
            ),
          ]
        )
        : const Center(
          child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
        )
      ),
    );
  }
);
