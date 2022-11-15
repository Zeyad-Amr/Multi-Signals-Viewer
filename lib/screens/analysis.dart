import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    Key key,
  }) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String startValidator(String val) {
    return int.tryParse(val) != null
        ? int.tryParse(val) > 0
            ? endVal.toInt() < startVal.toInt()
                ? 'Minimun temperature should be less Maximum'
                : null
            : 'Minimun temperature should be more than 0 C°'
        : 'Minimun temperature should be more than 0 C°';
  }

  String endValidator(String val) {
    return int.tryParse(val) != null
        ? int.tryParse(val) < 75
            ? endVal.toInt() < startVal.toInt()
                ? 'Minimun temperature should be less Maximum'
                : null
            : 'Minimun temperature should be less than 75 C°'
        : 'Minimun temperature should be less than 75 C°';
  }

  bool edit = false;
  int startVal;
  int endVal;
  final formGlobalKey = GlobalKey<FormState>();

  TextEditingController startCont;
  TextEditingController endCont;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 20),
                  child: Container(
                    width: 8,
                    height: 25,
                    color: Colors.red,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Text('Pulse oximeter:',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
              child: Text(
                  '1. The module uses a simple two-wire I2C interface for communication with the microcontroller. It has a fixed I2C address: 0xAEHEX (for write operation) and 0xAFHEX (for read operation)',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
              child: Text(
                  '2. Pulse oximetry is based on the principle that the amount of RED and IR light absorbed varies depending on the amount of oxygen in your blood.',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
