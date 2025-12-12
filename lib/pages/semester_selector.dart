import 'package:flutter/material.dart';

class SemesterSelector extends StatelessWidget {
  final String title;
  final Function(int semester) onSelect;

  const SemesterSelector({
    super.key,
    required this.title,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final neutralCardColor = Colors.white;
    final borderColor = Colors.grey.shade300;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: const Color(0xFF2E3A8C),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A8C),
          ),
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 16),

        itemBuilder: (context, index) {
          final sem = index + 1;

          return GestureDetector(
            onTap: () => onSelect(sem),

            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: neutralCardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Semester $sem",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A8C),
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF2E3A8C),
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
