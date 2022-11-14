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
                  child: Text('Restrictions',
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
                  '1. For usage, the patient is suffering from an injury causes knee Flexion or Extension issues.',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
              child: Text(
                  '2. Knee adduction or abduction are excluded from our analysis.',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
              child: Text(
                  '3. By using an elastic knee band and by fixing the used rounded sensor (FSR) pointing its rounded head slightly beneath the patella’s knee.',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
            Expanded(
                child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Image.asset('assets/warning.png'),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
