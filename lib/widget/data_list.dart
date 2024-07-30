import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sitilang_1_0_0/properties/media_size.dart';
import 'package:sitilang_1_0_0/properties/text.dart';
import 'package:sitilang_1_0_0/widget/notification.dart';

Widget DataList(context, {
  required File image,
  required String name,
  required String plat,
  required String imagePlat,
}) => Container(
  width: mediaWidth(context),
  height: 200,
  padding: const EdgeInsets.all(20),
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(width: 1, color: Colors.black),
    )
  ),
  child: Row(
    children: [
      InkWell(
        onTap: () {
          showSomethin(context, content: Image.file(image));
        },
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.file(image),
        ),
      ),
      Expanded(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$name WIB", style: dataListText,),
              Text(plat, style: dataListText),
              // InkWell(
              //   onTap: (){
              //     showSomethin(context, content: Image.asset(imagePlat));
              //   },
              //   child: SizedBox(
              //     width: 150,
              //     height: 60,
              //     child: Image.asset(imagePlat),
              //   ),
              // )
            ],
          ),
        )
      )
    ],
  ),
);