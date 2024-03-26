import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversionCard extends StatefulWidget {
  final rates;
  final Map currencies;
  const ConversionCard({
    Key? key,
    required this.rates,
    required this.currencies,
  }) : super(key: key);

  @override
  State<ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends State<ConversionCard> {
  TextEditingController amountController = TextEditingController();
  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
  String dropdownValue1 = 'USD';
  String dropdownValue2 = 'PKR';
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
            return Container(
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
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter an amount';
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
                  if (amountController.text.isEmpty) {
                    swapCurrencies();
                  } else {
                    swapCurrencies();
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
            style: Theme.of(context).textTheme.subtitle1,
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

const String key = '9dd5a322cdf542bc909c56fbd214645d';

class AppUrl {
  static const String baseUrl = 'https://openexchangerates.org/api/';
  static const String currenciesUrl = '${baseUrl}currencies.json?app_id=$key';
  static const String ratesUrl = '${baseUrl}latest.json?base=USD&app_id=$key';
}

RatesModel ratesModelFromJson(String str) =>
    RatesModel.fromJson(json.decode(str));

String ratesModelToJson(RatesModel data) => json.encode(data.toJson());

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

Map<String, String> allCurrenciesFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) => MapEntry<String, String>(k, v));

String allCurrenciesToJson(Map<String, String> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v)));

Future<RatesModel> fetchRates() async {
  var response = await http.get(Uri.parse(AppUrl.ratesUrl));
  final ratesModel = ratesModelFromJson(response.body);
  return ratesModel;
}

Future<Map> fetchCurrencies() async {
  var response = await http.get(Uri.parse(AppUrl.currenciesUrl));
  final allCurrencies = allCurrenciesFromJson(response.body);
  return allCurrencies;
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({Key? key});

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
