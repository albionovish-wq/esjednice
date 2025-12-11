import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/global.dart';

class PostavkeEkran extends ConsumerWidget {
  const PostavkeEkran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final korisnikData = ref.watch(korisnikPodaciProvider);

    return AppPageScaffold(
      title: 'Postavke',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Postavke',
            style: AppDesign.pageTitle,
          ),
          const SizedBox(height: AppDesign.spacingL),
          korisnikData.when(
            data: (korisnik) {
              if (korisnik == null) {
                return const Text('Korisnik nije pronađen');
              }

              return Container(
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
                      'Profil',
                      style: AppDesign.cardTitle,
                    ),
                    const SizedBox(height: AppDesign.spacingL),
                    InfoCard(
                      label: 'Ime i prezime',
                      value: korisnik.fullName,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: AppDesign.spacingM),
                    InfoCard(
                      label: 'Email',
                      value: korisnik.email,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: AppDesign.spacingM),
                    InfoCard(
                      label: 'Uloga',
                      value: korisnik.uloga.displayName,
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: AppDesign.spacingL),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesign.errorRed,
                      ),
                      onPressed: () async {
                        final authService = ref.read(authServiceProvider);
                        await authService.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/prijava');
                        }
                      },
                      child: const Text('Odjava'),
                    ),
                  ],
                ),
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
}
