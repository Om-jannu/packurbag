import 'package:flutter/material.dart';

import '../data/api_client.dart';

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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search currencies',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
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
                          title: Text('$currencyCode - $currencyName'),
                          onTap: () {
                            Navigator.pop(context, currencyCode);
                          },
                        );
                      },
                    ),
                  ),
                ],
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
        children: [
          TextFormField(
            key: formFieldKey,
            controller: amountController,
            decoration: const InputDecoration(
              hintText: 'Enter Amount',
              border: OutlineInputBorder(),
              labelText: 'Amount',
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
              IconButton(
                icon: const Icon(Icons.swap_vert),
                onPressed: () {
                  swapCurrencies();
                  if (amountController.text.trim().isEmpty) return;
                  if (formFieldKey.currentState?.validate() ?? false) {
                    convertAndDisplay();
                  }
                },
              ),
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
            onPressed: () {
              if (formFieldKey.currentState!.validate()) {
                startLoading();
                conversion = '';
                convertAndDisplay();
              }
            },
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Convert'),
          ),
          const SizedBox(height: 20),
          Text(
            conversion,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
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
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              onChanged(value);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
      ],
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
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: FutureBuilder<RatesModel>(
        future: ratesModel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return FutureBuilder<Map>(
              future: currenciesModel,
              builder: (context, index) {
                if (index.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
    );
  }
}
