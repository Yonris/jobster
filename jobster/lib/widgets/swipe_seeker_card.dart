import 'package:flutter/material.dart';
import '../../models/seeker_profile.dart';

class SwipeSeekerCard extends StatelessWidget {
  final SeekerProfile profile;

  const SwipeSeekerCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // to clip image corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          profile.photoUrl != null && profile.photoUrl!.isNotEmpty
              ? Image.network(
                  profile.photoUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : const SizedBox(
                  height: 200,
                  child: Icon(Icons.person, size: 100, color: Colors.grey),
                ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${profile.firstName} ${profile.lastName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                profile.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
