import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_shimmer_card.dart';

class ConversionCard extends StatefulWidget {
  final Map<String, double> rates;
  final Map<String, String> currencies;
  const ConversionCard({
    super.key,
    required this.rates,
    required this.currencies,
  });

  @override
  State<ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends State<ConversionCard> {
  TextEditingController amountController = TextEditingController();
  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
  String dropdownValue1 = 'INR';
  String dropdownValue2 = 'USD';
  String conversion = '';

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void convertAndDisplay() {
    setState(() {
      conversion =
          '${amountController.text} $dropdownValue1 = ${Utils.convert(widget.rates, amountController.text, dropdownValue1, dropdownValue2)} $dropdownValue2';
    });
  }

  void swapCurrencies() {
    setState(() {
      String temp = dropdownValue1;
      dropdownValue1 = dropdownValue2;
      dropdownValue2 = temp;
    });
    // The old result described the pre-swap pairing — either refresh it for
    // the new one or clear it, rather than leave it looking current.
    if (amountController.text.trim().isEmpty ||
        !(formFieldKey.currentState?.validate() ?? false)) {
      setState(() => conversion = '');
    } else {
      convertAndDisplay();
    }
  }

  void showCurrencyPicker(BuildContext context, String selectedCurrency) {
    String? searchQuery;
    // Only offer currencies this rates snapshot can actually convert —
    // Open Exchange Rates' currency catalog and its live rates aren't the
    // same set (e.g. the old Venezuelan Bolívar, VEF, is listed but has no
    // rate), and picking one that's missing a rate used to crash Convert.
    final pickable = widget.currencies.entries
        .where((entry) => widget.rates.containsKey(entry.key))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final visible = searchQuery == null
                ? pickable
                : pickable
                      .where(
                        (entry) =>
                            entry.key.toLowerCase().contains(searchQuery!) ||
                            entry.value.toLowerCase().contains(searchQuery!),
                      )
                      .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceInput(context),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: TextField(
                              autofocus: true,
                              style: AppTextStyles.body(
                                color: AppTheme.textPrimary(context),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search currencies',
                                hintStyle: AppTextStyles.body(
                                  color: AppTheme.textMuted(context),
                                ),
                                prefixIcon: Icon(
                                  LucideIcons.search,
                                  size: 18,
                                  color: AppTheme.textMuted(context),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            LucideIcons.x,
                            size: 18,
                            color: AppTheme.textMuted(context, opacity: 0.4),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (BuildContext context, int index) {
                          final entry = visible[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  entry.key,
                                  style: AppTextStyles.label(
                                    color: AppTheme.textPrimary(context),
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: AppTextStyles.caption(
                                      color: AppTheme.textMuted(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context, entry.key);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((selectedCurrencyCode) {
      if (selectedCurrencyCode == null) return;
      setState(() {
        if (selectedCurrency == 'dropdownValue1') {
          dropdownValue1 = selectedCurrencyCode;
        } else {
          dropdownValue2 = selectedCurrencyCode;
        }
      });
      if (conversion.isEmpty) return;
      // Same staleness concern as swap: the displayed result described the
      // pairing before this pick, not after.
      if (amountController.text.trim().isEmpty ||
          !(formFieldKey.currentState?.validate() ?? false)) {
        setState(() => conversion = '');
      } else {
        convertAndDisplay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Amount',
            style: AppTextStyles.caption(
              color: AppTheme.textMuted(context),
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: formFieldKey,
            controller: amountController,
            style: AppTextStyles.body(
              weight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: 'Enter Amount',
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide(color: AppTheme.borderMuted(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide(color: AppTheme.borderMuted(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                borderSide: BorderSide(
                  color: AppTheme.accent(context),
                  width: 1.5,
                ),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Please enter an amount';
              }
              final parsed = double.tryParse(trimmed);
              if (parsed == null) {
                return 'Enter a valid number';
              }
              if (parsed <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: DropdownRow(
                  label: 'From:',
                  value: dropdownValue1,
                  onChanged: (String? newValue) {
                    showCurrencyPicker(context, 'dropdownValue1');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: swapCurrencies,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.borderMuted(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.arrowUpDown,
                      size: 16,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownRow(
                  label: 'To:',
                  value: dropdownValue2,
                  onChanged: (String? newValue) {
                    showCurrencyPicker(context, 'dropdownValue2');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentStrong(context),
              foregroundColor: AppTheme.onAccentStrong(context),
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
            onPressed: () {
              if (formFieldKey.currentState?.validate() ?? false) {
                convertAndDisplay();
              }
            },
            child: Text(
              'Convert',
              style: AppTextStyles.bodyBold(
                color: AppTheme.onAccentStrong(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            conversion,
            style: AppTextStyles.appBarTitle(
              color: AppTheme.textPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String?) onChanged;

  const DropdownRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      onTap: () {
        onChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderMuted(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.caption(color: AppTheme.textMuted(context)),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyBold(
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                Icon(
                  LucideIcons.chevronDown,
                  size: 18,
                  color: AppTheme.textMuted(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Utils {
  static String convert(
    Map exchangeRates,
    String amount,
    String currencyBase,
    String currencyFinal,
  ) {
    final fromRate = exchangeRates[currencyBase];
    final toRate = exchangeRates[currencyFinal];
    if (fromRate == null || toRate == null) {
      // Shouldn't happen via the UI (the picker only offers currencies with
      // a rate), but this is cheap insurance against showing the original
      // amount labeled with the wrong currency rather than crashing.
      return amount;
    }
    double usdAmount = double.parse(amount) / (fromRate as num);
    return (usdAmount * (toRate as num)).toStringAsFixed(4);
  }
}

class RatesModel {
  RatesModel({
    required this.disclaimer,
    required this.license,
    required this.timestamp,
    required this.base,
    required this.rates,
  });

  String disclaimer;
  String license;
  int timestamp;
  String base;
  Map<String, double> rates;

  factory RatesModel.fromJson(Map<String, dynamic> json) => RatesModel(
    disclaimer: json["disclaimer"],
    license: json["license"],
    timestamp: json["timestamp"],
    base: json["base"],
    rates: Map.from(
      json["rates"],
    ).map((k, v) => MapEntry<String, double>(k, v.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "disclaimer": disclaimer,
    "license": license,
    "timestamp": timestamp,
    "base": base,
    "rates": Map.from(rates).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}

RatesModel? _cachedRates;
DateTime? _cachedRatesAt;
const _ratesCacheTtl = Duration(minutes: 15);

Map<String, String>? _cachedCurrencies;
DateTime? _cachedCurrenciesAt;
// Currency names/codes practically never change — a much longer TTL than
// rates is fine and saves a repeat fetch on every visit.
const _currenciesCacheTtl = Duration(hours: 24);

/// Both calls go through the backend so the Open Exchange Rates key never
/// ships in client source — see server/src/routes/currency.routes.ts.
Future<RatesModel> fetchRates({bool forceRefresh = false}) async {
  final cached = _cachedRates;
  final cachedAt = _cachedRatesAt;
  if (!forceRefresh &&
      cached != null &&
      cachedAt != null &&
      DateTime.now().difference(cachedAt) < _ratesCacheTtl) {
    return cached;
  }
  final data = await ApiClient.instance.get('/currency/rates');
  final model = RatesModel.fromJson(data);
  _cachedRates = model;
  _cachedRatesAt = DateTime.now();
  return model;
}

Future<Map<String, String>> fetchCurrencies({bool forceRefresh = false}) async {
  final cached = _cachedCurrencies;
  final cachedAt = _cachedCurrenciesAt;
  if (!forceRefresh &&
      cached != null &&
      cachedAt != null &&
      DateTime.now().difference(cachedAt) < _currenciesCacheTtl) {
    return cached;
  }
  final data = await ApiClient.instance.get('/currency/currencies');
  final map = data.map((k, v) => MapEntry(k, v.toString()));
  _cachedCurrencies = map;
  _cachedCurrenciesAt = DateTime.now();
  return map;
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  late Future<(RatesModel, Map<String, String>)> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<(RatesModel, Map<String, String>)> _loadData({
    bool forceRefresh = false,
  }) async {
    final results = await Future.wait([
      fetchRates(forceRefresh: forceRefresh),
      fetchCurrencies(forceRefresh: forceRefresh),
    ]);
    return (results[0] as RatesModel, results[1] as Map<String, String>);
  }

  void _retry() {
    setState(() {
      _dataFuture = _loadData(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderMuted(context)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      size: 20,
                      color: AppTheme.textPrimary(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Currency Converter',
                    style: AppTextStyles.appBarTitle(
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<(RatesModel, Map<String, String>)>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _ConverterFormShimmer();
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _ConverterErrorView(onRetry: _retry);
                  }
                  final (rates, currencies) = snapshot.data!;
                  return ConversionCard(
                    rates: rates.rates,
                    currencies: currencies,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConverterErrorView extends StatelessWidget {
  const _ConverterErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 36,
              color: AppTheme.textMuted(context),
            ),
            const SizedBox(height: 12),
            Text(
              "Couldn't load exchange rates",
              style: AppTextStyles.bodyBold(
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: AppTheme.textMuted(context)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentStrong(context),
                foregroundColor: AppTheme.onAccentStrong(context),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rough shape of the converter form (amount field, currency pickers,
/// convert button) — shown while rates/currencies load.
class _ConverterFormShimmer extends StatelessWidget {
  const _ConverterFormShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const LoadingShimmerCard(height: 64),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: LoadingShimmerCard(height: 56)),
              SizedBox(width: 12),
              Expanded(child: LoadingShimmerCard(height: 56)),
            ],
          ),
          const SizedBox(height: 16),
          const LoadingShimmerCard(height: 48, borderRadius: 999),
        ],
      ),
    );
  }
}
