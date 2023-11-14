import 'package:flutter/material.dart';
import 'package:tr_extension/tr_extension.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void reassemble() {
    // usefull for adding new translations while hot reloading
    Tr.to.reloadFiles();
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationsDelegates,
      home: const Home(),
    );
  }
}

var locale = const Locale('en', 'US');

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// these keys are located at:
            /// - assets/translations/en_US.json
            /// - assets/translations/pt_BR.json
            Text('helloWorld'.tr),
            ElevatedButton(
                onPressed: () {
                  final locale = Tr.to.locale == const Locale('pt', 'BR')
                      ? const Locale('en', 'US')
                      : const Locale('pt', 'BR');

                  Tr.to.changeLanguage(locale);
                },
                child: Text('changeLanguage'.tr))
          ],
        ),
      ),
    );
  }
}
