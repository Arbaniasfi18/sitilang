import 'package:flutter/material.dart';
import 'package:sitilang_1_0_0/properties/media_size.dart';
import 'package:sitilang_1_0_0/properties/text.dart';

Widget DataListSkeleton(context) => 
Container(
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
      AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          color: Colors.grey,
        )
      ),
      Expanded(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("10:20 WIB", style: dataListText,),
              Text("BK XXXX AA", style: dataListText),
              Container(
                width: 150,
                height: 40,
                color: Colors.grey,
              )
            ],
          ),
        )
      )
    ],
  ),
);