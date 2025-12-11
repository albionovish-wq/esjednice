import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/sjednice.dart';

class DetaljiSjedniceEkran extends ConsumerWidget {
  final String sjednicaId;

  const DetaljiSjedniceEkran({
    Key? key,
    required this.sjednicaId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sjednicaAsync = ref.watch(pojedinacnaSjednicaProvider(sjednicaId));

    return AppPageScaffold(
      title: 'Detalji Sjednice',
      body: sjednicaAsync.when(
        data: (sjednica) {
          if (sjednica == null) {
            return const Center(
              child: Text('Sjednica nije pronađena'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sjednica.naslov,
                          style: AppDesign.pageTitle,
                        ),
                        const SizedBox(height: AppDesign.spacingM),
                        StatusChip(status: sjednica.status),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit screen
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppDesign.spacingL),

              // Info section
              Container(
                padding: const EdgeInsets.all(AppDesign.spacingL),
                decoration: BoxDecoration(
                  color: AppDesign.white,
                  borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                  border: Border.all(color: AppDesign.borderGray),
                  boxShadow: [AppDesign.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Osnovne informacije',
                      style: AppDesign.cardTitle,
                    ),
                    const SizedBox(height: AppDesign.spacingL),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppDesign.spacingM,
                      crossAxisSpacing: AppDesign.spacingM,
                      children: [
                        InfoCard(
                          icon: Icons.calendar_today,
                          label: 'Datum i vrijeme',
                          value: DateFormat('dd.MM.yyyy HH:mm').format(sjednica.vrijeme),
                        ),
                        InfoCard(
                          icon: Icons.location_on,
                          label: 'Lokacija',
                          value: sjednica.lokacija ?? 'Nije navedena',
                        ),
                        InfoCard(
                          icon: Icons.groups,
                          label: 'Grupa',
                          value: sjednica.grupa,
                        ),
                        InfoCard(
                          icon: Icons.person,
                          label: 'Sazivač',
                          value: sjednica.sazivac,
                        ),
                      ],
                    ),
                    if (sjednica.opis != null) ...[
                      const SizedBox(height: AppDesign.spacingL),
                      Text(
                        'Opis',
                        style: AppDesign.labelText,
                      ),
                      const SizedBox(height: AppDesign.spacingS),
                      Text(
                        sjednica.opis!,
                        style: AppDesign.bodyText,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDesign.spacingL),

              // Agenda section
              if (sjednica.dnevniRed.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppDesign.spacingL),
                  decoration: BoxDecoration(
                    color: AppDesign.white,
                    borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                    border: Border.all(color: AppDesign.borderGray),
                    boxShadow: [AppDesign.cardShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dnevni red',
                        style: AppDesign.cardTitle,
                      ),
                      const SizedBox(height: AppDesign.spacingL),
                      ...sjednica.dnevniRed.map((stavka) {
                        return DnevniRedItem(
                          rednibroj: stavka.rednibroj,
                          naslov: stavka.naslov,
                          opis: stavka.opis,
                          saGlasanjem: stavka.saGlasanjem,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppDesign.spacingL),
              ],

              // Attendance section
              if (sjednica.prisutnost.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppDesign.spacingL),
                  decoration: BoxDecoration(
                    color: AppDesign.white,
                    borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                    border: Border.all(color: AppDesign.borderGray),
                    boxShadow: [AppDesign.cardShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prisutnost',
                        style: AppDesign.cardTitle,
                      ),
                      const SizedBox(height: AppDesign.spacingL),
                      // Count summary
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppDesign.spacingM),
                              decoration: BoxDecoration(
                                color: AppDesign.successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Prisutni',
                                    style: AppDesign.labelText,
                                  ),
                                  Text(
                                    sjednica.prisutnost
                                        .where((p) => p.prisutan)
                                        .length
                                        .toString(),
                                    style: AppDesign.pageTitle.copyWith(
                                      fontSize: 24,
                                      color: AppDesign.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDesign.spacingM),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppDesign.spacingM),
                              decoration: BoxDecoration(
                                color: AppDesign.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Odsutni',
                                    style: AppDesign.labelText,
                                  ),
                                  Text(
                                    sjednica.prisutnost
                                        .where((p) => !p.prisutan)
                                        .length
                                        .toString(),
                                    style: AppDesign.pageTitle.copyWith(
                                      fontSize: 24,
                                      color: AppDesign.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesign.spacingL),
                      // Attendance list
                      ...sjednica.prisutnost.map((p) {
                        return PrisutnostItem(
                          ime: p.ime,
                          prezime: p.prezime,
                          prisutan: p.prisutan,
                        );
                      }),
                    ],
                  ),
                ),
              ],
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
}
