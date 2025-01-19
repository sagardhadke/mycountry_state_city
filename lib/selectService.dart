import 'package:flutter/material.dart';
import 'package:mycountry_state_city/CountryStateCityPicker.dart';
import 'package:mycountry_state_city/locator.dart';

class MySelectionBtn extends StatelessWidget {
  const MySelectionBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyCountryPick()),
                );
              },
              child: const Text('Country Picker'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white),
              onPressed: () {
                // send to state picker
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => locator()),
                );
              },
              child: const Text('Locator UI'),
            ),
          ],
        ),
      ),
    );
  }
}
