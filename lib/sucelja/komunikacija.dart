import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/obavijesti.dart';
import 'package:esjednice/modeli/obavijest.dart';

class KomunikacijaEkran extends ConsumerStatefulWidget {
  const KomunikacijaEkran({Key? key}) : super(key: key);

  @override
  ConsumerState<KomunikacijaEkran> createState() => _KomunikacijaEkranState();
}

class _KomunikacijaEkranState extends ConsumerState<KomunikacijaEkran> {
  ObavijestTip? _selectedTip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obavijesti = ref.watch(obavijrestiProvider);

    return AppPageScaffold(
      title: 'Komunikacija',
      body: obavijesti.when(
        data: (obavijestList) {
          final filtered = _selectedTip == null
              ? obavijestList
              : obavijestList.where((o) => o.tip == _selectedTip).toList();

          if (obavijestList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail,
                    size: 64,
                    color: AppDesign.borderGray,
                  ),
                  const SizedBox(height: AppDesign.spacingM),
                  Text(
                    'Nema dostupnih obavijesti',
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
                'Obavijesti',
                style: AppDesign.pageTitle,
              ),
              const SizedBox(height: AppDesign.spacingL),
              // Filter section
              Container(
                padding: const EdgeInsets.all(AppDesign.spacingM),
                decoration: BoxDecoration(
                  color: AppDesign.white,
                  borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                  border: Border.all(color: AppDesign.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtriraj po tipu:',
                      style: AppDesign.labelText,
                    ),
                    const SizedBox(height: AppDesign.spacingS),
                    Wrap(
                      spacing: AppDesign.spacingS,
                      children: [
                        FilterChip(
                          label: const Text('Sve'),
                          selected: _selectedTip == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTip = null;
                            });
                          },
                        ),
                        ...ObavijestTip.values.map((tip) {
                          return FilterChip(
                            label: Text(tip.displayName),
                            selected: _selectedTip == tip,
                            onSelected: (selected) {
                              setState(() {
                                _selectedTip = selected ? tip : null;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDesign.spacingL),
              Text(
                '${filtered.length} obavijesti',
                style: AppDesign.bodyTextSmall,
              ),
              const SizedBox(height: AppDesign.spacingM),
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDesign.spacingL),
                    child: Text(
                      'Nema obavijesti koje odgovaraju vašim kriterijima',
                      style: AppDesign.bodyText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppDesign.spacingM),
                  itemBuilder: (context, index) {
                    final obavijest = filtered[index];
                    return _buildObavijestCard(context, obavijest);
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

  Widget _buildObavijestCard(BuildContext context, Obavijest obavijest) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/obavijest',
          arguments: obavijest.id,
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
                    obavijest.naslov,
                    style: AppDesign.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.spacingS,
                    vertical: AppDesign.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesign.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
                    border: Border.all(color: AppDesign.primaryBlue),
                  ),
                  child: Text(
                    obavijest.tip.displayName,
                    style: AppDesign.labelText.copyWith(
                      color: AppDesign.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesign.spacingM),
            Text(
              obavijest.sadrzaj,
              style: AppDesign.bodyTextSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDesign.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppDesign.darkBlue,
                      size: 14,
                    ),
                    const SizedBox(width: AppDesign.spacingXs),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(obavijest.vrijeme),
                      style: AppDesign.bodyTextSmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: AppDesign.darkBlue,
                      size: 14,
                    ),
                    const SizedBox(width: AppDesign.spacingXs),
                    Text(
                      obavijest.autoriziranoIme,
                      style: AppDesign.bodyTextSmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
