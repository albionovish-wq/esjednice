import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/sjednice.dart';
import 'package:esjednice/provideri/sjednice_notifier.dart';
import 'package:esjednice/modeli/sjednica.dart';

class DetaljiSjedniceEkran extends ConsumerStatefulWidget {
  final String sjednicaId;

  const DetaljiSjedniceEkran({
    Key? key,
    required this.sjednicaId,
  }) : super(key: key);

  @override
  ConsumerState<DetaljiSjedniceEkran> createState() =>
      _DetaljiSjedniceEkranState();
}

class _DetaljiSjedniceEkranState extends ConsumerState<DetaljiSjedniceEkran> {
  late Map<String, bool> _prisutnostMap;

  void _initializePrisutnostMap(Sjednica sjednica) {
    _prisutnostMap = {};
    for (final p in sjednica.prisutnost) {
      _prisutnostMap[p.korisnikId] = p.prisutan;
    }
  }

  Future<void> _updatePrisutnost(Sjednica sjednica) async {
    final updatedPrisutnost = sjednica.prisutnost.map((p) {
      final newStatus = _prisutnostMap[p.korisnikId] ?? p.prisutan;
      return p.copyWith(prisutan: newStatus);
    }).toList();

    await ref
        .read(sjedniceNotifierProvider.notifier)
        .updatePrisutnost(
          sjednicaId: widget.sjednicaId,
          prisutnost: updatedPrisutnost,
        );
  }

  void _changeStatus(Sjednica sjednica, SjednicaStatus newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promijeni status'),
        content: Text(
          'Jeste li sigurni da želite promijeniti status na "${newStatus.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Potvrdi'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(sjedniceNotifierProvider.notifier)
          .updateSjednicaStatus(
            sjednicaId: widget.sjednicaId,
            newStatus: newStatus,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status promijenjen na ${newStatus.displayName}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sjednicaAsync = ref.watch(pojedinacnaSjednicaProvider(widget.sjednicaId));

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
                  if (sjednica.status == SjednicaStatus.planned)
                   IconButton(
                     icon: const Icon(Icons.edit),
                     onPressed: () {
                       Navigator.pushNamed(
                         context,
                         '/uredi-sjednica',
                         arguments: sjednica.id,
                       );
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

              // Status transition buttons (if applicable)
              if (sjednica.status != SjednicaStatus.canceled &&
                  sjednica.status != SjednicaStatus.concluded) ...[
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
                        'Akcije',
                        style: AppDesign.cardTitle,
                      ),
                      const SizedBox(height: AppDesign.spacingL),
                      Row(
                        children: [
                          if (sjednica.status == SjednicaStatus.planned) ...[
                            ElevatedButton(
                              onPressed: () =>
                                  _changeStatus(sjednica, SjednicaStatus.inProgress),
                              child: const Text('Započni sjednico'),
                            ),
                            const SizedBox(width: AppDesign.spacingM),
                          ],
                          if (sjednica.status == SjednicaStatus.inProgress) ...[
                            ElevatedButton(
                              onPressed: () =>
                                  _changeStatus(sjednica, SjednicaStatus.concluded),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppDesign.successGreen,
                              ),
                              child: const Text('Završi sjednico'),
                            ),
                            const SizedBox(width: AppDesign.spacingM),
                          ],
                          ElevatedButton(
                            onPressed: () =>
                                _changeStatus(sjednica, SjednicaStatus.canceled),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppDesign.errorRed,
                            ),
                            child: const Text('Otkaži sjednico'),
                          ),
                        ],
                      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prisutnost',
                            style: AppDesign.cardTitle,
                          ),
                          if (sjednica.status == SjednicaStatus.inProgress)
                            ElevatedButton(
                              onPressed: () async {
                                if (_prisutnostMap.isEmpty) {
                                  _initializePrisutnostMap(sjednica);
                                }
                                await _updatePrisutnost(sjednica);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Prisutnost ažurirana')),
                                  );
                                }
                              },
                              child: const Text('Spremi'),
                            ),
                        ],
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
                      if (sjednica.status == SjednicaStatus.inProgress)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sjednica.prisutnost.length,
                          itemBuilder: (context, index) {
                            final p = sjednica.prisutnost[index];
                            final status = _prisutnostMap.isNotEmpty
                                ? _prisutnostMap[p.korisnikId] ?? p.prisutan
                                : p.prisutan;
                            return Container(
                              margin: const EdgeInsets.only(
                                  bottom: AppDesign.spacingS),
                              child: CheckboxListTile(
                                title: Text('${p.ime} ${p.prezime}'),
                                value: status,
                                onChanged: (value) {
                                  setState(() {
                                    _prisutnostMap[p.korisnikId] = value ?? false;
                                  });
                                },
                              ),
                            );
                          },
                        )
                      else
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
