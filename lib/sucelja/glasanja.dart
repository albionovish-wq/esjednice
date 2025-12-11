import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';

class GlasanjaEkran extends ConsumerWidget {
  const GlasanjaEkran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppPageScaffold(
      title: 'Glasanja',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_vote,
              size: 64,
              color: AppDesign.borderGray,
            ),
            const SizedBox(height: AppDesign.spacingM),
            Text(
              'Glasanja - Uskoro dostupno',
              style: AppDesign.cardTitle,
            ),
          ],
        ),
      ),
    );
  }
}
