import 'package:flutter/material.dart';
import 'package:tr_extension/tr_extension.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: TrDelegate(),
      locale: context.locale,
      supportedLocales: const [Locale('en', 'US'), Locale('pt', 'BR')],
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
            Text('hello_world'.tr),
            Text(DateTime.now().jms()),
            Text('1200000000.4'.compactSimpleCurrency()),
            Text('1200000000.4'.compactCurrency()),
            ElevatedButton(
              onPressed: () {
                final locale = context.locale == const Locale('pt', 'BR')
                    ? const Locale('en', 'US')
                    : const Locale('pt', 'BR');

                context.setLocale(locale);
              },
              child: Text('change_language'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
