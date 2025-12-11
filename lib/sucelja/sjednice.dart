import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/sjednice.dart';
import 'package:esjednice/modeli/sjednica.dart';

class SjedniceEkran extends ConsumerStatefulWidget {
  const SjedniceEkran({Key? key}) : super(key: key);

  @override
  ConsumerState<SjedniceEkran> createState() => _SjedniceEkranState();
}

class _SjedniceEkranState extends ConsumerState<SjedniceEkran> {
  late TextEditingController _searchController;
  SjednicaStatus? _selectedStatus;
  List<Sjednica> _filteredSjednice = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSjednice);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSjednice() {
    final sjednice = ref.read(sjedniceProvider).value ?? [];
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredSjednice = sjednice.where((sjednica) {
        final matchesSearch = sjednica.naslov.toLowerCase().contains(query) ||
            sjednica.grupa.toLowerCase().contains(query);
        final matchesStatus =
            _selectedStatus == null || sjednica.status == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sjednice = ref.watch(sjedniceProvider);

    return AppPageScaffold(
      title: 'Sjednice',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/kreiraj-sjednica');
        },
        child: const Icon(Icons.add),
      ),
      body: sjednice.when(
        data: (sjedniceList) {
          if (_filteredSjednice.isEmpty && _searchController.text.isEmpty) {
            _filteredSjednice = sjedniceList;
          } else if (_filteredSjednice.isEmpty) {
            _filterSjednice();
          }

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
              // Search and filter section
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
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Traži po naslovu ili grupi...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterSjednice();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppDesign.spacingM),
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
                            _filterSjednice();
                          },
                        ),
                        ...SjednicaStatus.values.map((status) {
                          return FilterChip(
                            label: Text(status.displayName),
                            selected: _selectedStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : null;
                              });
                              _filterSjednice();
                            },
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDesign.spacingL),
              // Results count
              Text(
                '${_filteredSjednice.length} rezultata',
                style: AppDesign.bodyTextSmall,
              ),
              const SizedBox(height: AppDesign.spacingM),
              // Meetings list
              if (_filteredSjednice.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDesign.spacingL),
                    child: Text(
                      'Nema sjednica koje odgovaraju vašim kriterijima',
                      style: AppDesign.bodyText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredSjednice.length,
                  separatorBuilder: (_, __) => const SizedBox(
                    height: AppDesign.spacingM,
                  ),
                  itemBuilder: (context, index) {
                    final sjednica = _filteredSjednice[index];
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
            const SizedBox(height: AppDesign.spacingS),
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: AppDesign.darkBlue,
                  size: 16,
                ),
                const SizedBox(width: AppDesign.spacingS),
                Text(
                  sjednica.grupa,
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
                  if (sjednica.dnevniRed.any((stavka) => stavka.saGlasanjem)) ...[
                    const SizedBox(width: AppDesign.spacingM),
                    Icon(
                      Icons.how_to_vote,
                      color: AppDesign.primaryBlue,
                      size: 14,
                    ),
                    const SizedBox(width: AppDesign.spacingXs),
                    Text(
                      'Glasanja dostupna',
                      style: AppDesign.bodyTextSmall.copyWith(
                        color: AppDesign.primaryBlue,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
