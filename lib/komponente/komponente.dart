import 'package:flutter/material.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/modeli/sjednica.dart';

class AppPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final AppBar? appBar;
  final Widget? floatingActionButton;

  const AppPageScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.lightGray,
      appBar: appBar ??
          AppBar(
            title: Text(title),
            elevation: 1,
          ),
      body: Row(
        children: [
          AppSidebar(
            currentTitle: title,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDesign.spacingL),
                child: body,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class AppSidebar extends StatelessWidget {
  final String currentTitle;

  const AppSidebar({
    Key? key,
    required this.currentTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppDesign.white,
      border: Border(
        right: BorderSide(
          color: AppDesign.borderGray,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(AppDesign.spacingM),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppDesign.borderGray,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'eSjednice',
              style: AppDesign.cardTitle,
            ),
          ),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home,
                  label: 'Početna',
                  route: '/dashboard',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.groups,
                  label: 'Grupe',
                  route: '/groups',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.how_to_vote,
                  label: 'Glasanja',
                  route: '/voting',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.event,
                  label: 'Sjednice',
                  route: '/meetings',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.mail,
                  label: 'Komunikacija',
                  route: '/communication',
                ),
              ],
            ),
          ),
          // Settings
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppDesign.borderGray,
                  width: 1,
                ),
              ),
            ),
            child: _buildNavItem(
              context,
              icon: Icons.settings,
              label: 'Postavke',
              route: '/settings',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = label == currentTitle;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppDesign.primaryBlue : AppDesign.darkBlue,
      ),
      title: Text(
        label,
        style: AppDesign.bodyText.copyWith(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppDesign.primaryBlue : AppDesign.darkBlue,
        ),
      ),
      selected: isActive,
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const AppAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const InfoCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.spacingM),
      decoration: BoxDecoration(
        color: AppDesign.white,
        borderRadius: BorderRadius.circular(AppDesign.cardRadius),
        border: Border.all(color: AppDesign.borderGray),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppDesign.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: AppDesign.spacingM),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppDesign.labelText),
              const SizedBox(height: AppDesign.spacingXs),
              Text(value, style: AppDesign.bodyText),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final SjednicaStatus status;

  const StatusChip({
    Key? key,
    required this.status,
  }) : super(key: key);

  Color get statusColor {
    switch (status) {
      case SjednicaStatus.planned:
        return AppDesign.warningYellow;
      case SjednicaStatus.inProgress:
        return AppDesign.primaryBlue;
      case SjednicaStatus.concluded:
        return AppDesign.successGreen;
      case SjednicaStatus.canceled:
        return AppDesign.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.spacingM,
        vertical: AppDesign.spacingXs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        status.displayName,
        style: AppDesign.labelText.copyWith(color: statusColor),
      ),
    );
  }
}

class DnevniRedItem extends StatelessWidget {
  final int rednibroj;
  final String naslov;
  final String? opis;
  final bool saGlasanjem;

  const DnevniRedItem({
    Key? key,
    required this.rednibroj,
    required this.naslov,
    this.opis,
    this.saGlasanjem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDesign.spacingM),
      padding: const EdgeInsets.all(AppDesign.spacingM),
      decoration: BoxDecoration(
        color: AppDesign.white,
        borderRadius: BorderRadius.circular(AppDesign.cardRadius),
        border: Border.all(color: AppDesign.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppDesign.primaryBlue,
                  borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                ),
                child: Center(
                  child: Text(
                    rednibroj.toString(),
                    style: AppDesign.buttonText,
                  ),
                ),
              ),
              const SizedBox(width: AppDesign.spacingM),
              Expanded(
                child: Text(
                  naslov,
                  style: AppDesign.cardTitle,
                ),
              ),
              if (saGlasanjem)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.spacingS,
                    vertical: AppDesign.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesign.primaryBlue,
                    borderRadius: BorderRadius.circular(AppDesign.buttonRadius),
                  ),
                  child: Text(
                    'Sa glasanjem',
                    style: AppDesign.labelText.copyWith(
                      color: AppDesign.white,
                    ),
                  ),
                ),
            ],
          ),
          if (opis != null) ...[
            const SizedBox(height: AppDesign.spacingM),
            Text(
              opis!,
              style: AppDesign.bodyText,
            ),
          ],
        ],
      ),
    );
  }
}

class PrisutnostItem extends StatelessWidget {
  final String ime;
  final String prezime;
  final bool prisutan;

  const PrisutnostItem({
    Key? key,
    required this.ime,
    required this.prezime,
    required this.prisutan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.spacingM,
        vertical: AppDesign.spacingS,
      ),
      margin: const EdgeInsets.only(bottom: AppDesign.spacingS),
      decoration: BoxDecoration(
        color: prisutan ? AppDesign.successGreen.withOpacity(0.1) : AppDesign.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesign.cardRadius),
        border: Border.all(
          color: prisutan ? AppDesign.successGreen : AppDesign.errorRed,
        ),
      ),
      child: Row(
        children: [
          Icon(
            prisutan ? Icons.check_circle : Icons.cancel,
            color: prisutan ? AppDesign.successGreen : AppDesign.errorRed,
          ),
          const SizedBox(width: AppDesign.spacingM),
          Text(
            '$ime $prezime',
            style: AppDesign.bodyText,
          ),
        ],
      ),
    );
  }
}
