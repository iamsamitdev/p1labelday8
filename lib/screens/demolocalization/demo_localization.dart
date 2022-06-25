// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

// แสดงภาษาต่างๆ
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DemoLocalizationScreen extends StatefulWidget {
  DemoLocalizationScreen({Key? key}) : super(key: key);

  @override
  State<DemoLocalizationScreen> createState() => _DemoLocalizationScreenState();
}

class _DemoLocalizationScreenState extends State<DemoLocalizationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localization'),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.hello),
      ),
    );
  }
}