import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/responsive_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'QuizForge',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final children = <Widget>[
            _NavCard(title: 'Play Quiz', onTap: () => context.go('/play')),
            _NavCard(title: 'Question Bank', onTap: () => context.go('/questions')),
            _NavCard(title: 'Add Question', onTap: () => context.go('/questions/new')),
            _NavCard(title: 'Stats', onTap: () => context.go('/stats')),
          ];

          return isTablet
              ? GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: children,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (_, i) => children[i],
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: children.length,
                );
        },
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _NavCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}