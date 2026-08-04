import 'package:flutter/material.dart';

class NewNoteBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const NewNoteBanner({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage("assets/images/notes_banner.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add),
            label: const Text("New Note"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 15,
            ),
          ),
        ),
      ),
    );
  }
}