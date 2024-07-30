import 'package:flutter/material.dart';
import 'package:sitilang_1_0_0/properties/color.dart';
import 'package:sitilang_1_0_0/properties/spacing.dart';
import 'package:sitilang_1_0_0/properties/text.dart';
import 'package:sitilang_1_0_0/screen/data.dart';
import 'package:sitilang_1_0_0/screen/scan.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset("assets/images/background.jpeg",)
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.jpg", width: 250,),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: (){
              
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanPage()));
                      
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                      child: Text("Scan", 
                        style: button,
                      ),
                    ),
                  ),
                  HeightSpacing(20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: (){

                        // Navigator.pushNamed(context, '/test');
              
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPage("")));
              
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                      child: Text("Data", 
                        style: button
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}
