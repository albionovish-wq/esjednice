import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/glasanja.dart';
import 'package:esjednice/modeli/glasanje.dart';

class GlasanjaEkran extends ConsumerStatefulWidget {
  const GlasanjaEkran({Key? key}) : super(key: key);

  @override
  ConsumerState<GlasanjaEkran> createState() => _GlasanjaEkranState();
}

class _GlasanjaEkranState extends ConsumerState<GlasanjaEkran> {
  GlasanjeStatus? _selectedStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glasanja = ref.watch(glasanjaProvider);

    return AppPageScaffold(
      title: 'Glasanja',
      body: glasanja.when(
        data: (glasanjaList) {
          final filtered = _selectedStatus == null
              ? glasanjaList
              : glasanjaList.where((g) => g.status == _selectedStatus).toList();

          if (glasanjaList.isEmpty) {
            return Center(
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
                    'Nema dostupnih glasanja',
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
                'Glasanja',
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
                      'Filtriraj po statusu:',
                      style: AppDesign.labelText,
                    ),
                    const SizedBox(height: AppDesign.spacingS),
                    Wrap(
                      spacing: AppDesign.spacingS,
                      children: [
                        FilterChip(
                          label: const Text('Sve'),
                          selected: _selectedStatus == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = null;
                            });
                          },
                        ),
                        ...GlasanjeStatus.values.map((status) {
                          return FilterChip(
                            label: Text(status.displayName),
                            selected: _selectedStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : null;
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
                '${filtered.length} rezultata',
                style: AppDesign.bodyTextSmall,
              ),
              const SizedBox(height: AppDesign.spacingM),
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDesign.spacingL),
                    child: Text(
                      'Nema glasanja koja odgovaraju vašim kriterijima',
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
                    final glasanje = filtered[index];
                    return _buildGlasanjeCard(context, glasanje, ref);
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

  Widget _buildGlasanjeCard(BuildContext context, Glasanje glasanje, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/glasanje',
          arguments: glasanje.id,
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
                    glasanje.naslov,
                    style: AppDesign.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                  'Do: ${DateFormat('dd.MM.yyyy HH:mm').format(glasanje.krajnjeVrijeme)}',
                  style: AppDesign.bodyTextSmall,
                ),
              ],
            ),
            const SizedBox(height: AppDesign.spacingS),
            Row(
              children: [
                Icon(
                  Icons.how_to_vote,
                  color: AppDesign.darkBlue,
                  size: 16,
                ),
                const SizedBox(width: AppDesign.spacingS),
                Text(
                  '${glasanje.glasovi.length} glasova',
                  style: AppDesign.bodyTextSmall,
                ),
              ],
            ),
            if (glasanje.opis != null) ...[
              const SizedBox(height: AppDesign.spacingM),
              Text(
                glasanje.opis!,
                style: AppDesign.bodyTextSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
