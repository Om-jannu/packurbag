import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_shimmer_card.dart';

class ConversionCard extends StatefulWidget {
  final Map<String, double> rates;
  final Map currencies;
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
  bool isLoading = false;

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void stopLoading() {
    setState(() {
      isLoading = false;
    });
  }

  void convertAndDisplay() {
    conversion =
        '${amountController.text} $dropdownValue1 = ${Utils.convert(widget.rates, amountController.text, dropdownValue1, dropdownValue2)} $dropdownValue2';
    stopLoading();
  }

  void swapCurrencies() {
    setState(() {
      String temp = dropdownValue1;
      dropdownValue1 = dropdownValue2;
      dropdownValue2 = temp;
    });
  }

  void showCurrencyPicker(BuildContext context, String selectedCurrency) {
    String? searchQuery;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                              style: AppTextStyles.body(color: AppTheme.textPrimary(context)),
                              decoration: InputDecoration(
                                hintText: 'Search currencies',
                                hintStyle: AppTextStyles.body(color: AppTheme.textMuted(context)),
                                prefixIcon: Icon(LucideIcons.search, size: 18, color: AppTheme.textMuted(context)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                          icon: Icon(LucideIcons.x, size: 18, color: AppTheme.textMuted(context, opacity: 0.4)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.currencies.length,
                        itemBuilder: (BuildContext context, int index) {
                          String currencyCode =
                              widget.currencies.keys.elementAt(index);
                          String currencyName = widget.currencies[currencyCode]!;

                          // Filter currencies based on search query
                          if (searchQuery != null &&
                              !currencyCode
                                  .toLowerCase()
                                  .contains(searchQuery!) &&
                              !currencyName
                                  .toLowerCase()
                                  .contains(searchQuery!)) {
                            return Container();
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            title: Row(
                              children: [
                                Text(
                                  currencyCode,
                                  style: AppTextStyles.label(
                                    color: AppTheme.textPrimary(context),
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    currencyName,
                                    style: AppTextStyles.caption(color: AppTheme.textMuted(context)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context, currencyCode);
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
      if (selectedCurrencyCode != null) {
        setState(() {
          selectedCurrency == 'dropdownValue1'
              ? dropdownValue1 = selectedCurrencyCode
              : dropdownValue2 = selectedCurrencyCode;
        });
      }
    });
  }

  void onKeyboardTap(String value) {
    setState(() {
      amountController.text += value;
    });
  }

  Widget buildKeyboardButton(String text) {
    return Expanded(
      child: TextButton(
        onPressed: () => onKeyboardTap(text),
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget buildKeyboardRow(List<String> rowValues) {
    return Row(
      children: rowValues.map((value) => buildKeyboardButton(value)).toList(),
    );
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
            style: AppTextStyles.caption(color: AppTheme.textMuted(context)).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: formFieldKey,
            controller: amountController,
            style: AppTextStyles.body(weight: FontWeight.w700, color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Enter Amount',
              filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                borderSide: BorderSide(color: AppTheme.accent(context), width: 1.5),
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
            children: [
              Expanded(
                child: DropdownRow(
                  label: 'From:',
                  value: dropdownValue1,
                  currencies: widget.currencies,
                  onChanged: (String? newValue) {
                    showCurrencyPicker(context, 'dropdownValue1');
                  },
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  swapCurrencies();
                  if (amountController.text.trim().isEmpty) return;
                  if (formFieldKey.currentState?.validate() ?? false) {
                    convertAndDisplay();
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.borderMuted(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.arrowUpDown, size: 16, color: AppTheme.textPrimary(context)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownRow(
                  label: 'To:',
                  value: dropdownValue2,
                  currencies: widget.currencies,
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
              if (formFieldKey.currentState!.validate()) {
                startLoading();
                conversion = '';
                convertAndDisplay();
              }
            },
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.onAccentStrong(context)),
                  )
                : Text('Convert', style: AppTextStyles.bodyBold(color: AppTheme.onAccentStrong(context))),
          ),
          const SizedBox(height: 20),
          Text(
            conversion,
            style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
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
  final Map currencies;
  final void Function(String?) onChanged;

  const DropdownRow({
    super.key,
    required this.label,
    required this.value,
    required this.currencies,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderMuted(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: AppTextStyles.bodyBold(color: AppTheme.textPrimary(context))),
            Icon(LucideIcons.chevronDown, size: 18, color: AppTheme.textMuted(context)),
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
    double usdAmount = double.parse(amount) / exchangeRates[currencyBase];
    String output =
        (usdAmount * exchangeRates[currencyFinal]).toStringAsFixed(4);
    return output;
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
        rates: Map.from(json["rates"])
            .map((k, v) => MapEntry<String, double>(k, v.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "disclaimer": disclaimer,
        "license": license,
        "timestamp": timestamp,
        "base": base,
        "rates": Map.from(rates).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

/// Both calls go through the backend so the Open Exchange Rates key never
/// ships in client source — see server/server.js `/currency/rates` and
/// `/currency/currencies`.
Future<RatesModel> fetchRates() async {
  final data = await ApiClient.instance.get('/currency/rates');
  return RatesModel.fromJson(data);
}

Future<Map<String, String>> fetchCurrencies() async {
  final data = await ApiClient.instance.get('/currency/currencies');
  return data.map((k, v) => MapEntry(k, v.toString()));
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  late Future<RatesModel> ratesModel;
  late Future<Map> currenciesModel;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    ratesModel = fetchRates();
    currenciesModel = fetchCurrencies();
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
                border: Border(bottom: BorderSide(color: AppTheme.borderMuted(context))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.arrowLeft, size: 20, color: AppTheme.textPrimary(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Currency Converter',
                    style: AppTextStyles.appBarTitle(color: AppTheme.textPrimary(context)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<RatesModel>(
                future: ratesModel,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _ConverterFormShimmer();
                  } else {
                    return FutureBuilder<Map>(
                      future: currenciesModel,
                      builder: (context, index) {
                        if (index.connectionState == ConnectionState.waiting) {
                          return const _ConverterFormShimmer();
                        } else if (index.hasError) {
                          return Center(child: Text('Error: ${index.error}'));
                        } else {
                          return ConversionCard(
                            rates: snapshot.data!.rates,
                            currencies: index.data!,
                          );
                        }
                      },
                    );
                  }
                },
              ),
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
