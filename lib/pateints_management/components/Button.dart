import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final void Function()? onTap;
   
  const Button({super.key, required this.text , required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
onTap: onTap,
    
    child:Container(
      decoration: BoxDecoration(
        color:const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(9),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Text(text),
      ),
    ),
    );
  }
}
