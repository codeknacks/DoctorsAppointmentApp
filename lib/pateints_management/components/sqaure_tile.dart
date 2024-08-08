import 'package:flutter/material.dart';

class SqaureTile extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;

  const SqaureTile({
    super.key,
    required this.imagePath,
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: const Color.fromARGB(255, 255, 244, 244)
        ),
        child: Image.asset(
          imagePath,
          height: 40,
         
        ),
      ),
    );
  }
}