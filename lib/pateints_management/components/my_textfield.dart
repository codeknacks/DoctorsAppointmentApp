import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyTextfield extends StatefulWidget {
  final String hintText ; 
  final Color hintColor;
  final bool obscureText;
  final Color color;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  
  
 const MyTextfield({super.key,
  required this.hintText,
  required this.hintColor,
  required this.obscureText,
  required this.controller,
  required this.color,
 this.validator,
  this.focusNode
  
  
  });

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          obscureText: widget.obscureText,
          controller: widget.controller ,
          focusNode: widget.focusNode,
          
          
          
          
          decoration: InputDecoration(
              
              enabledBorder:const OutlineInputBorder(
                 borderSide: BorderSide(
                  color: Color.fromARGB(255, 255, 251, 251),
                  width: 1,
                  
                  
                ),
              ),
              focusedBorder:const  OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 0, 0, 0),
                  width: 3
                ),
              ),
              
              hintText: widget.hintText,
              hintStyle: TextStyle(color: widget.hintColor),
              
              
              
              
              ),
              style: const TextStyle(color: Color.fromARGB(255, 6, 6, 6)),
              
        ),
      ),
    );
  }
}
