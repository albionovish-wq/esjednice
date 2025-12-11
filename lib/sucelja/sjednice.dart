import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/sjednice.dart';
import 'package:esjednice/modeli/sjednica.dart';

class SjedniceEkran extends ConsumerWidget {
  const SjedniceEkran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sjednice = ref.watch(sjedniceProvider);

    return AppPageScaffold(
      title: 'Sjednice',
      body: sjednice.when(
        data: (sjedniceList) {
          if (sjedniceList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event,
                    size: 64,
                    color: AppDesign.borderGray,
                  ),
                  const SizedBox(height: AppDesign.spacingM),
                  Text(
                    'Nema dostupnih sjednica',
                    style: AppDesign.cardTitle,
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sve sjednice',
                style: AppDesign.pageTitle,
              ),
              const SizedBox(height: AppDesign.spacingL),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sjedniceList.length,
                separatorBuilder: (_, __) => const SizedBox(
                  height: AppDesign.spacingM,
                ),
                itemBuilder: (context, index) {
                  final sjednica = sjedniceList[index];
                  return _buildSjednicaCard(context, sjednica);
                },
              ),
            ],
          );
        },
        error: (error, stack) => Center(
          child: Text('Greška: $error'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildSjednicaCard(BuildContext context, Sjednica sjednica) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/sjednica',
          arguments: sjednica.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppDesign.spacingM),
        decoration: BoxDecoration(
          color: AppDesign.white,
          borderRadius: BorderRadius.circular(AppDesign.cardRadius),
          border: Border.all(color: AppDesign.borderGray),
          boxShadow: [AppDesign.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sjednica.naslov,
                    style: AppDesign.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusChip(status: sjednica.status),
              ],
            ),
            const SizedBox(height: AppDesign.spacingM),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppDesign.darkBlue,
                  size: 16,
                ),
                const SizedBox(width: AppDesign.spacingS),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(sjednica.vrijeme),
                  style: AppDesign.bodyTextSmall,
                ),
              ],
            ),
            const SizedBox(height: AppDesign.spacingS),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppDesign.darkBlue,
                  size: 16,
                ),
                const SizedBox(width: AppDesign.spacingS),
                Text(
                  sjednica.lokacija ?? 'Nije navedena',
                  style: AppDesign.bodyTextSmall,
                ),
              ],
            ),
            if (sjednica.dnevniRed.isNotEmpty) ...[
              const SizedBox(height: AppDesign.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.list,
                    color: AppDesign.darkBlue,
                    size: 16,
                  ),
                  const SizedBox(width: AppDesign.spacingS),
                  Text(
                    '${sjednica.dnevniRed.length} stavki',
                    style: AppDesign.bodyTextSmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
