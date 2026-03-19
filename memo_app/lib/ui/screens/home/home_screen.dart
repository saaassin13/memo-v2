import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'widgets/apps_grid.dart';

/// Home screen displaying date header and apps grid
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Text(
                '今天',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 24),
              // Apps grid
              const AppsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
