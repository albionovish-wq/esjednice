import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/glasanja.dart';
import 'package:esjednice/provideri/glasanja_notifier.dart';
import 'package:esjednice/provideri/global.dart';

class DetaljiGlasanjaEkran extends ConsumerStatefulWidget {
  final String glasanjeId;

  const DetaljiGlasanjaEkran({
    Key? key,
    required this.glasanjeId,
  }) : super(key: key);

  @override
  ConsumerState<DetaljiGlasanjaEkran> createState() =>
      _DetaljiGlasanjaEkranState();
}

class _DetaljiGlasanjaEkranState extends ConsumerState<DetaljiGlasanjaEkran> {
  String? _odabraniIzbor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glasanjeAsync =
        ref.watch(pojedinacnoGlasanjeProvider(widget.glasanjeId));
    final korisnikData = ref.watch(korisnikPodaciProvider).value;
    final userVoted = ref.watch(userVotedProvider(widget.glasanjeId));

    return glasanjeAsync.when(
      data: (glasanje) {
        if (glasanje == null) {
          return const AppPageScaffold(
            title: 'Detalji glasanja',
            body: Center(child: Text('Glasanje nije pronađeno')),
          );
        }

        final korisnikGlas = korisnikData != null
            ? glasanje.glasovi.where((g) => g.korisnikId == korisnikData.uid).firstOrNull
            : null;

        return AppPageScaffold(
          title: 'Detalji glasanja',
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  glasanje.naslov,
                  style: AppDesign.pageTitle,
                ),
                const SizedBox(height: AppDesign.spacingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.spacingM,
                    vertical: AppDesign.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: glasanje.isOpen
                        ? AppDesign.successGreen.withOpacity(0.1)
                        : AppDesign.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
                    border: Border.all(
                      color: glasanje.isOpen
                          ? AppDesign.successGreen
                          : AppDesign.errorRed,
                    ),
                  ),
                  child: Text(
                    glasanje.status.displayName,
                    style: AppDesign.labelText.copyWith(
                      color: glasanje.isOpen
                          ? AppDesign.successGreen
                          : AppDesign.errorRed,
                    ),
                  ),
                ),
                const SizedBox(height: AppDesign.spacingL),

                // Info section
                if (glasanje.opis != null)
                  Container(
                    padding: const EdgeInsets.all(AppDesign.spacingL),
                    decoration: BoxDecoration(
                      color: AppDesign.white,
                      borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                      border: Border.all(color: AppDesign.borderGray),
                    ),
                    margin: const EdgeInsets.only(bottom: AppDesign.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opis',
                          style: AppDesign.labelText,
                        ),
                        const SizedBox(height: AppDesign.spacingS),
                        Text(
                          glasanje.opis!,
                          style: AppDesign.bodyText,
                        ),
                      ],
                    ),
                  ),

                // Timeline section
                Container(
                  padding: const EdgeInsets.all(AppDesign.spacingL),
                  decoration: BoxDecoration(
                    color: AppDesign.white,
                    borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                    border: Border.all(color: AppDesign.borderGray),
                  ),
                  margin: const EdgeInsets.only(bottom: AppDesign.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vremenski period',
                        style: AppDesign.cardTitle,
                      ),
                      const SizedBox(height: AppDesign.spacingL),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Početak',
                                  style: AppDesign.labelText,
                                ),
                                const SizedBox(height: AppDesign.spacingXs),
                                Text(
                                  DateFormat('dd.MM.yyyy HH:mm')
                                      .format(glasanje.pocetneVrijeme),
                                  style: AppDesign.bodyText,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kraj',
                                  style: AppDesign.labelText,
                                ),
                                const SizedBox(height: AppDesign.spacingXs),
                                Text(
                                  DateFormat('dd.MM.yyyy HH:mm')
                                      .format(glasanje.krajnjeVrijeme),
                                  style: AppDesign.bodyText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Voting section
                Container(
                  padding: const EdgeInsets.all(AppDesign.spacingL),
                  decoration: BoxDecoration(
                    color: AppDesign.white,
                    borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                    border: Border.all(color: AppDesign.borderGray),
                  ),
                  margin: const EdgeInsets.only(bottom: AppDesign.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Glasanje',
                        style: AppDesign.cardTitle,
                      ),
                      const SizedBox(height: AppDesign.spacingL),
                      if (korisnikGlas != null)
                        Container(
                          padding: const EdgeInsets.all(AppDesign.spacingM),
                          decoration: BoxDecoration(
                            color: AppDesign.successGreen.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppDesign.cardRadius),
                            border: Border.all(
                                color: AppDesign.successGreen),
                          ),
                          margin: const EdgeInsets.only(
                              bottom: AppDesign.spacingL),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppDesign.successGreen,
                              ),
                              const SizedBox(width: AppDesign.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ste već glasali',
                                      style: AppDesign.labelText,
                                    ),
                                    const SizedBox(
                                        height: AppDesign.spacingXs),
                                    Text(
                                      'Vaš izbor: ${korisnikGlas.izbor}',
                                      style: AppDesign.bodyText,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (glasanje.isOpen && korisnikGlas == null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Odaberite opciju:',
                              style: AppDesign.labelText,
                            ),
                            const SizedBox(height: AppDesign.spacingM),
                            ...glasanje.opcije.map((opcija) {
                              return Container(
                                margin: const EdgeInsets.only(
                                    bottom: AppDesign.spacingS),
                                child: Material(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _odabraniIzbor = opcija;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          AppDesign.spacingM),
                                      decoration: BoxDecoration(
                                        color: _odabraniIzbor == opcija
                                            ? AppDesign.primaryBlue
                                            : AppDesign.lightGray,
                                        borderRadius: BorderRadius.circular(
                                            AppDesign.cardRadius),
                                        border: Border.all(
                                          color: _odabraniIzbor == opcija
                                              ? AppDesign.primaryBlue
                                              : AppDesign.borderGray,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: opcija,
                                            groupValue: _odabraniIzbor,
                                            onChanged: (value) {
                                              setState(() {
                                                _odabraniIzbor = value;
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                              width: AppDesign.spacingM),
                                          Text(
                                            opcija,
                                            style: AppDesign.bodyText
                                                .copyWith(
                                              color: _odabraniIzbor ==
                                                      opcija
                                                  ? AppDesign.white
                                                  : AppDesign.darkBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: AppDesign.spacingL),
                            ElevatedButton(
                              onPressed: _odabraniIzbor == null
                                  ? null
                                  : () async {
                                      if (korisnikData == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Korisnik nije pronađen')),
                                        );
                                        return;
                                      }

                                      try {
                                        await ref
                                            .read(
                                                glasanjaNotifierProvider
                                                    .notifier)
                                            .castVote(
                                              glasanjeId:
                                                  widget.glasanjeId,
                                              korisnikId: korisnikData.uid,
                                              izbor: _odabraniIzbor!,
                                            );

                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Glasovanje uspješno')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Greška: $e')),
                                        );
                                      }
                                    },
                              child: const Text('Glasuj'),
                            ),
                          ],
                        )
                      else if (glasanje.isClosed)
                        Text(
                          'Glasovanje je završeno',
                          style: AppDesign.bodyText,
                        ),
                    ],
                  ),
                ),

                // Results section
                if (glasanje.isClosed || korisnikGlas != null)
                  Container(
                    padding: const EdgeInsets.all(AppDesign.spacingL),
                    decoration: BoxDecoration(
                      color: AppDesign.white,
                      borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                      border: Border.all(color: AppDesign.borderGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rezultati',
                          style: AppDesign.cardTitle,
                        ),
                        const SizedBox(height: AppDesign.spacingL),
                        ...glasanje.rezultati.entries.map((entry) {
                          final percentage = glasanje.glasovi.isEmpty
                              ? 0.0
                              : (entry.value / glasanje.glasovi.length) * 100;
                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: AppDesign.spacingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: AppDesign.bodyText,
                                    ),
                                    Text(
                                      '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                      style: AppDesign.labelText,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDesign.spacingXs),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppDesign.buttonRadius),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 8,
                                    backgroundColor:
                                        AppDesign.borderGray,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      AppDesign.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: AppDesign.spacingM),
                        Text(
                          'Ukupno glasova: ${glasanje.glasovi.length}',
                          style: AppDesign.bodyTextSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      error: (error, stack) => AppPageScaffold(
        title: 'Detalji glasanja',
        body: Center(child: Text('Greška: $error')),
      ),
      loading: () => const AppPageScaffold(
        title: 'Detalji glasanja',
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
