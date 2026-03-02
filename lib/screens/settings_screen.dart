import 'package:flutter/material.dart';
import 'package:gym_cronometro/l10n/app_localizations.dart';
import 'package:gym_cronometro/main.dart';
import 'package:gym_cronometro/themes/app_themes.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onResetSets;

  const SettingsScreen({super.key, required this.onResetSets});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        final theme = themeProvider.currentTheme;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.background,
            foregroundColor: theme.text,
            title: Text(l10n.settings),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionTitle(label: l10n.vibration, theme: theme),
              const SizedBox(height: 8),
              _buildVibrationTile(theme),
              const SizedBox(height: 28),
              _SectionTitle(label: l10n.language, theme: theme),
              const SizedBox(height: 8),
              _buildLanguageSelector(theme),
              const SizedBox(height: 28),
              _SectionTitle(label: l10n.theme, theme: theme),
              const SizedBox(height: 8),
              _buildThemeGrid(context, theme, l10n),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    onResetSets();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.resetColor,
                    side: BorderSide(color: theme.resetColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.resetSets,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Gym Timer',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 Arthur Bolsoni. All rights reserved.',
                      applicationIcon: const Icon(Icons.timer, size: 48),
                    );
                  },
                  icon: Icon(Icons.info_outline, color: theme.textSecondary),
                  label: Text(
                    l10n.about,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textSecondary,
                    side: BorderSide(color: theme.textSecondary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVibrationTile(AppThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: themeProvider.vibrationEnabled,
        onChanged: (val) => themeProvider.setVibration(val),
        activeTrackColor: theme.accent,
        activeThumbColor: theme.text,
        title: Icon(Icons.vibration, color: theme.text),
      ),
    );
  }

  Widget _buildLanguageSelector(AppThemeData theme) {
    const locales = [
      (Locale('pt'), 'Português', '🇧🇷'),
      (Locale('en'), 'English', '🇺🇸'),
      (Locale('es'), 'Español', '🇪🇸'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: locales.map((entry) {
          final (locale, name, flag) = entry;
          final isSelected = themeProvider.locale.languageCode == locale.languageCode;

          return ListTile(
            leading: Text(flag, style: const TextStyle(fontSize: 24)),
            title: Text(name, style: TextStyle(color: theme.text)),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: theme.accent)
                : null,
            onTap: () => themeProvider.setLocale(locale),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeGrid(BuildContext context, AppThemeData currentTheme, AppLocalizations l10n) {
    final themes = appThemes.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final entry = themes[index];
        final t = entry.value;
        final isSelected = currentTheme.id == t.id;
        final name = themeLocalizedName(t.id, l10n);

        return GestureDetector(
          onTap: () => themeProvider.setTheme(t.id),
          child: Container(
            decoration: BoxDecoration(
              color: t.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? t.accent : t.surface,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _colorDot(t.buttonColor),
                    const SizedBox(width: 4),
                    _colorDot(t.accent),
                    const SizedBox(width: 4),
                    _colorDot(t.resetColor),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: t.text,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(Icons.check, size: 16, color: t.accent),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final AppThemeData theme;

  const _SectionTitle({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
