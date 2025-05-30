import 'package:flutter/material.dart';
import 'package:taxi_app/language/localization.dart'; // مسار صحيح

class OfficeManagerSettingsPage extends StatelessWidget {
  final int officeId;
  const OfficeManagerSettingsPage({super.key, required this.officeId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
          AppLocalizations.of(context)
              .translate('office_drivers_management_content'),
          style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
