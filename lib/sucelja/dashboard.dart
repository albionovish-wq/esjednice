import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/komponente/komponente.dart';
import 'package:esjednice/provideri/global.dart';
import 'package:esjednice/provideri/sjednice.dart';

class DashboardEkran extends ConsumerWidget {
  const DashboardEkran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final korisnikData = ref.watch(korisnikPodaciProvider);
    final sjednicasStats = ref.watch(sjedniceStatsProvider);

    return AppPageScaffold(
      title: 'Početna',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          korisnikData.when(
            data: (korisnik) {
              return Text(
                'Dobrodošao, ${korisnik?.fullName ?? 'Korisniče'}!',
                style: AppDesign.pageTitle,
              );
            },
            error: (_, __) => Text(
              'Dobrodošao!',
              style: AppDesign.pageTitle,
            ),
            loading: () => const SizedBox(
              height: 30,
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: AppDesign.spacingL),
          // Stats cards
          sjednicasStats.when(
            data: (stats) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppDesign.spacingM,
                crossAxisSpacing: AppDesign.spacingM,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Planirane',
                    value: stats['planned']?.toString() ?? '0',
                    icon: Icons.schedule,
                    color: AppDesign.warningYellow,
                    onTap: () {
                      Navigator.pushNamed(context, '/meetings');
                    },
                  ),
                  _buildStatCard(
                    context,
                    title: 'U tijeku',
                    value: stats['inProgress']?.toString() ?? '0',
                    icon: Icons.play_circle,
                    color: AppDesign.primaryBlue,
                    onTap: () {
                      Navigator.pushNamed(context, '/meetings');
                    },
                  ),
                  _buildStatCard(
                    context,
                    title: 'Završene',
                    value: stats['concluded']?.toString() ?? '0',
                    icon: Icons.check_circle,
                    color: AppDesign.successGreen,
                    onTap: () {
                      Navigator.pushNamed(context, '/meetings');
                    },
                  ),
                  _buildStatCard(
                    context,
                    title: 'Otkazane',
                    value: stats['canceled']?.toString() ?? '0',
                    icon: Icons.cancel,
                    color: AppDesign.errorRed,
                    onTap: () {
                      Navigator.pushNamed(context, '/meetings');
                    },
                  ),
                ],
              );
            },
            error: (_, __) => const Text('Greška pri učitavanju podataka'),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: AppDesign.spacingL),
          // Quick access section
          Text(
            'Brz pristup',
            style: AppDesign.cardTitle,
          ),
          const SizedBox(height: AppDesign.spacingM),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppDesign.spacingM,
            crossAxisSpacing: AppDesign.spacingM,
            children: [
              _buildQuickAccessCard(
                context,
                title: 'Sjednice',
                icon: Icons.event,
                route: '/meetings',
              ),
              _buildQuickAccessCard(
                context,
                title: 'Glasanja',
                icon: Icons.how_to_vote,
                route: '/voting',
              ),
              _buildQuickAccessCard(
                context,
                title: 'Grupe',
                icon: Icons.groups,
                route: '/groups',
              ),
              _buildQuickAccessCard(
                context,
                title: 'Komunikacija',
                icon: Icons.mail,
                route: '/communication',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppDesign.spacingM),
            Text(
              value,
              style: AppDesign.pageTitle.copyWith(
                fontSize: 24,
                color: color,
              ),
            ),
            const SizedBox(height: AppDesign.spacingXs),
            Text(
              title,
              style: AppDesign.bodyText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
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
              icon,
              color: AppDesign.primaryBlue,
              size: 40,
            ),
            const SizedBox(height: AppDesign.spacingM),
            Text(
              title,
              style: AppDesign.cardTitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
