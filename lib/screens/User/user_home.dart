import 'package:flutter/material.dart';
import 'package:taxi_app/language/localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCarType;
  String? selectedPaymentMethod = "cash";
  bool hasActiveRide = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              (kToolbarHeight + MediaQuery.of(context).padding.top),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🚖 ${local.translate('new_ride_request')}",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Location inputs
            _buildLocationInput(
              context,
              "📍 ${local.translate('current_location')}",
              local.translate('enter_your_location'),
            ),
            const SizedBox(height: 10),
            _buildLocationInput(
              context,
              "🎯 ${local.translate('destination')}",
              local.translate('where_to'),
            ),
            const SizedBox(height: 15),

            // Car type selector
            _buildCarTypeSelector(context),
            const SizedBox(height: 10),

            // Fare estimate and payment
            _buildEstimateFareAndPayment(context),
            const SizedBox(height: 20),

            // Request ride button
            _buildRequestRideButton(context),
            const SizedBox(height: 20),

            // Active ride info if available
            if (hasActiveRide) _buildActiveRideInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput(
    BuildContext context,
    String label,
    String hint,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: theme.cardColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCarTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "🚗 ${local.translate('choose_car_type')}",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCarTypeOption(context, "economy"),
              const SizedBox(width: 10),
              _buildCarTypeOption(context, "luxury"),
              const SizedBox(width: 10),
              _buildCarTypeOption(context, "family"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarTypeOption(BuildContext context, String type) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    final isSelected = selectedCarType == type;

    return ChoiceChip(
      label: Text(local.translate(type)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedCarType = selected ? type : null;
        });
      },
      backgroundColor: theme.cardColor,
      selectedColor: theme.colorScheme.secondary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildEstimateFareAndPayment(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "💰 ${local.translate('fare_estimate')}",
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  "15-20 ${local.translate('currency')}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              value: selectedPaymentMethod,
              items: ["cash", "card", "wallet"].map((String method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(local.translate(method)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedPaymentMethod = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestRideButton(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            hasActiveRide = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "🚖 ${local.translate('request_ride')}",
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveRideInfo(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🚖 ${local.translate('active_ride')}",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Rest of your active ride info...
          ],
        ),
      ),
    );
  }
}
