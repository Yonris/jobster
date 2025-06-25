import 'package:flutter/material.dart';
import '../models/job_posting.dart';

class SwipeCard extends StatelessWidget {
  final JobPosting data;

  const SwipeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(data.description),
            const SizedBox(height: 12),
            Text('Location: ${data.location}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: data.requirements
                  .map((req) => Chip(label: Text(req)))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
