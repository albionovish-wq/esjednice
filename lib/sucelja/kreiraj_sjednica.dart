import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/modeli/sjednica.dart';
import 'package:esjednice/provideri/global.dart';
import 'package:esjednice/provideri/sjednice_notifier.dart';
import 'package:uuid/uuid.dart';

class KreirajSjednicuEkran extends ConsumerStatefulWidget {
  const KreirajSjednicuEkran({Key? key}) : super(key: key);

  @override
  ConsumerState<KreirajSjednicuEkran> createState() =>
      _KreirajSjednicuEkranState();
}

class _KreirajSjednicuEkranState extends ConsumerState<KreirajSjednicuEkran> {
  late final TextEditingController _naslovController;
  late final TextEditingController _opisController;
  late final TextEditingController _lokacijaController;
  DateTime? _odabraniDatum;
  TimeOfDay? _odabranoVrijeme;
  String? _odabranaGrupa;
  List<DnevniRedStavka> _dnevniRed = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _naslovController = TextEditingController();
    _opisController = TextEditingController();
    _lokacijaController = TextEditingController();
    _odabraniDatum = DateTime.now();
    _odabranoVrijeme = TimeOfDay.now();
  }

  @override
  void dispose() {
    _naslovController.dispose();
    _opisController.dispose();
    _lokacijaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _odabraniDatum ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _odabraniDatum = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _odabranoVrijeme ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _odabranoVrijeme = picked;
      });
    }
  }

  void _dodajStavkuDnevnogReda() {
    showDialog(
      context: context,
      builder: (context) => _StavkaDnevnogRedaDialog(
        onAdd: (stavka) {
          setState(() {
            final novaStavka = DnevniRedStavka(
              id: const Uuid().v4(),
              rednibroj: _dnevniRed.length + 1,
              naslov: stavka['naslov'] as String,
              opis: stavka['opis'] as String?,
              saGlasanjem: stavka['saGlasanjem'] as bool? ?? false,
            );
            _dnevniRed.add(novaStavka);
          });
        },
      ),
    );
  }

  void _ukloniStavku(int index) {
    setState(() {
      _dnevniRed.removeAt(index);
      // Re-number remaining items
      for (int i = 0; i < _dnevniRed.length; i++) {
        _dnevniRed[i] = _dnevniRed[i].copyWith(rednibroj: i + 1);
      }
    });
  }

  void _copyWith(DnevniRedStavka stavka, {required int rednibroj}) {
    // Placeholder for copyWith method
  }

  Future<void> _kreirajSjednica() async {
    if (_naslovController.text.isEmpty) {
      setState(() => _errorMessage = 'Naslov je obavezan');
      return;
    }

    if (_odabranaGrupa == null) {
      setState(() => _errorMessage = 'Grupa je obavezna');
      return;
    }

    if (_odabraniDatum == null || _odabranoVrijeme == null) {
      setState(() => _errorMessage = 'Datum i vrijeme su obavezni');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final korisnikData = ref.read(korisnikPodaciProvider).value;
      if (korisnikData == null) throw Exception('Korisnik nije pronađen');

      final vrijeme = DateTime(
        _odabraniDatum!.year,
        _odabraniDatum!.month,
        _odabraniDatum!.day,
        _odabranoVrijeme!.hour,
        _odabranoVrijeme!.minute,
      );

      await ref.read(sjedniceNotifierProvider.notifier).createSjednica(
            naslov: _naslovController.text,
            opis: _opisController.text.isEmpty ? null : _opisController.text,
            grupa: _odabranaGrupa!,
            vrijeme: vrijeme,
            lokacija:
                _lokacijaController.text.isEmpty ? null : _lokacijaController.text,
            sazivac: korisnikData.uid,
            zapisnicar: korisnikData.uid,
            dnevniRed: _dnevniRed,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sjednica uspješno kreirana')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Greška: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grupeAsync = ref.watch(korisnikGrupeProvider);

    return AppPageScaffold(
      title: 'Nova sjednica',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppDesign.spacingM),
                margin: const EdgeInsets.only(bottom: AppDesign.spacingM),
                decoration: BoxDecoration(
                  color: AppDesign.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                  border: Border.all(color: AppDesign.errorRed),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppDesign.bodyText.copyWith(
                    color: AppDesign.errorRed,
                  ),
                ),
              ),
            // Osnovni podaci
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
                    'Osnovni podaci',
                    style: AppDesign.cardTitle,
                  ),
                  const SizedBox(height: AppDesign.spacingL),
                  TextField(
                    controller: _naslovController,
                    decoration: const InputDecoration(
                      labelText: 'Naslov sjednice *',
                      prefixIcon: Icon(Icons.event),
                    ),
                  ),
                  const SizedBox(height: AppDesign.spacingM),
                  TextField(
                    controller: _opisController,
                    decoration: const InputDecoration(
                      labelText: 'Opis (opciono)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppDesign.spacingM),
                  grupeAsync.when(
                    data: (grupe) {
                      return DropdownButtonFormField<String>(
                        value: _odabranaGrupa,
                        hint: const Text('Odaberi grupu *'),
                        items: grupe
                            .map((grupa) => DropdownMenuItem(
                                  value: grupa,
                                  child: Text(grupa),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _odabranaGrupa = value);
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.groups),
                        ),
                      );
                    },
                    error: (_, __) => const Text('Greška pri učitavanju grupa'),
                    loading: () =>
                        const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: AppDesign.spacingM),
                  TextField(
                    controller: _lokacijaController,
                    decoration: const InputDecoration(
                      labelText: 'Lokacija (opciono)',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesign.spacingL),
            // Datum i vrijeme
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
                    'Datum i vrijeme',
                    style: AppDesign.cardTitle,
                  ),
                  const SizedBox(height: AppDesign.spacingL),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(AppDesign.spacingM),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppDesign.borderGray),
                              borderRadius:
                                  BorderRadius.circular(AppDesign.buttonRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Datum',
                                  style: AppDesign.labelText,
                                ),
                                const SizedBox(height: AppDesign.spacingXs),
                                Text(
                                  DateFormat('dd.MM.yyyy')
                                      .format(_odabraniDatum!),
                                  style: AppDesign.bodyText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDesign.spacingM),
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(AppDesign.spacingM),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppDesign.borderGray),
                              borderRadius:
                                  BorderRadius.circular(AppDesign.buttonRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vrijeme',
                                  style: AppDesign.labelText,
                                ),
                                const SizedBox(height: AppDesign.spacingXs),
                                Text(
                                  _odabranoVrijeme!.format(context),
                                  style: AppDesign.bodyText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesign.spacingL),
            // Dnevni red
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dnevni red',
                        style: AppDesign.cardTitle,
                      ),
                      ElevatedButton.icon(
                        onPressed: _dodajStavkuDnevnogReda,
                        icon: const Icon(Icons.add),
                        label: const Text('Dodaj'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDesign.spacingL),
                  if (_dnevniRed.isEmpty)
                    Text(
                      'Nema stavki. Dodaj stavku da bih nastavio.',
                      style: AppDesign.bodyTextSmall,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dnevniRed.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppDesign.spacingM),
                      itemBuilder: (context, index) {
                        final stavka = _dnevniRed[index];
                        return Container(
                          padding: const EdgeInsets.all(AppDesign.spacingM),
                          decoration: BoxDecoration(
                            color: AppDesign.lightGray,
                            borderRadius:
                                BorderRadius.circular(AppDesign.cardRadius),
                            border: Border.all(color: AppDesign.borderGray),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${stavka.rednibroj}. ${stavka.naslov}',
                                      style: AppDesign.bodyText,
                                    ),
                                    if (stavka.opis != null) ...[
                                      const SizedBox(
                                          height: AppDesign.spacingXs),
                                      Text(
                                        stavka.opis!,
                                        style: AppDesign.bodyTextSmall,
                                      ),
                                    ],
                                    if (stavka.saGlasanjem) ...[
                                      const SizedBox(
                                          height: AppDesign.spacingXs),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDesign.spacingS,
                                          vertical: AppDesign.spacingXs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppDesign.primaryBlue,
                                          borderRadius:
                                              BorderRadius.circular(
                                                AppDesign.buttonRadius,
                                              ),
                                        ),
                                        child: Text(
                                          'Sa glasanjem',
                                          style: AppDesign.labelText.copyWith(
                                            color: AppDesign.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _ukloniStavku(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDesign.spacingL),
            // Akcije
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Odustani'),
                ),
                const SizedBox(width: AppDesign.spacingM),
                ElevatedButton(
                  onPressed: _isLoading ? null : _kreirajSjednica,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kreiraj sjednico'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StavkaDnevnogRedaDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _StavkaDnevnogRedaDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<_StavkaDnevnogRedaDialog> createState() =>
      _StavkaDnevnogRedaDialogState();
}

class _StavkaDnevnogRedaDialogState extends State<_StavkaDnevnogRedaDialog> {
  late final TextEditingController _naslovController;
  late final TextEditingController _opisController;
  bool _saGlasanjem = false;

  @override
  void initState() {
    super.initState();
    _naslovController = TextEditingController();
    _opisController = TextEditingController();
  }

  @override
  void dispose() {
    _naslovController.dispose();
    _opisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj stavku dnevnog reda'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _naslovController,
            decoration: const InputDecoration(
              labelText: 'Naslov stavke *',
              prefixIcon: Icon(Icons.list_alt),
            ),
          ),
          const SizedBox(height: AppDesign.spacingM),
          TextField(
            controller: _opisController,
            decoration: const InputDecoration(
              labelText: 'Opis (opciono)',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppDesign.spacingM),
          CheckboxListTile(
            title: const Text('Stavka zahtijeva glasanje'),
            value: _saGlasanjem,
            onChanged: (value) {
              setState(() => _saGlasanjem = value ?? false);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: _naslovController.text.isEmpty
              ? null
              : () {
                  widget.onAdd({
                    'naslov': _naslovController.text,
                    'opis':
                        _opisController.text.isEmpty ? null : _opisController.text,
                    'saGlasanjem': _saGlasanjem,
                  });
                  Navigator.pop(context);
                },
          child: const Text('Dodaj'),
        ),
      ],
    );
  }
}
