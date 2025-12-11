import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/global.dart';

class GrupeEkran extends ConsumerWidget {
  const GrupeEkran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grupeAsync = ref.watch(korisnikGrupeProvider);

    return AppPageScaffold(
      title: 'Grupe',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Moje grupe',
            style: AppDesign.pageTitle,
          ),
          const SizedBox(height: AppDesign.spacingL),
          grupeAsync.when(
            data: (grupe) {
              if (grupe.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups,
                        size: 64,
                        color: AppDesign.borderGray,
                      ),
                      const SizedBox(height: AppDesign.spacingM),
                      Text(
                        'Nisi član nijedne grupe',
                        style: AppDesign.cardTitle,
                      ),
                    ],
                  ),
                );
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppDesign.spacingM,
                crossAxisSpacing: AppDesign.spacingM,
                children: grupe
                    .map((grupa) => _buildGrupaCard(context, grupa))
                    .toList(),
              );
            },
            error: (error, stack) => Center(
              child: Text('Greška: $error'),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrupaCard(BuildContext context, String grupa) {
    return GestureDetector(
      onTap: () {
        // Navigate to group details
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppDesign.white,
          borderRadius: BorderRadius.circular(AppDesign.cardRadius),
          border: Border.all(color: AppDesign.borderGray),
          boxShadow: [AppDesign.cardShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              color: AppDesign.primaryBlue,
              size: 48,
            ),
            const SizedBox(height: AppDesign.spacingM),
            Text(
              grupa,
              style: AppDesign.cardTitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
