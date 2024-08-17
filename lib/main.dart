import 'dart:convert';
import 'package:currency_exchange/Models/currencies.dart';
import 'package:currency_exchange/Models/countryDropdown.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Currency App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Currencies> currencies = [];

  String dropdownvalue = 'USD';
  @override
  void initState() {
    super.initState();
    fetchCurrencies(dropdownvalue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(86, 100, 245, 70),
        title: Text(
          'Currency Exchange',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width / 20),
        ),
        leading: const Icon(
          Icons.currency_exchange,
          color: Colors.white,
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(
        //       Icons.menu,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {
        //       // do something
        //     },
        //   )
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
              child: Text(
                'Select Currency',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width / 22),
              ),
            ),
            DropdownButtonFormField(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 0.5,
                  ),
                ),
              ),
              value: dropdownvalue,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
              items: currencyCountryDropdown.map((Map<String, String> item) {
                return DropdownMenuItem<String>(
                  value: item['currency'],
                  child: Text(
                    '${item['currency']} - ${item['name']}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                  fetchCurrencies(dropdownvalue);
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  String currency = currencies[index].country;
                  String? countryCode = currencyCountryDropdown.firstWhere(
                      (element) => element['currency'] == currency,
                      orElse: () => {'country': 'us'})['country'];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CountryFlag.fromCountryCode(
                        countryCode!,
                        height: 48,
                        width: 62,
                        borderRadius: 8,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            currencies[index].country,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(currencies[index].rate.toString()),
                        ],
                      ),
                      // subtitle: Text(currencies[index].rate.toString()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchCurrencies(dropdownvalue) async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/$dropdownvalue');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      currencies.clear();
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic> rates = data['rates'];

      rates.forEach((country, rate) {
        currencies.add(Currencies(country, rate.toDouble()));
      });
      setState(() {});
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }
}
