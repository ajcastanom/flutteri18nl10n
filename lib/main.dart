import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutteri18nl10n/src/blocs/preferences_bloc.dart';
import 'package:flutteri18nl10n/src/presentation/styles/theme.dart';
import 'package:flutteri18nl10n/src/presentation/widgets/expansion_list_card.dart';
import 'package:flutteri18nl10n/src/presentation/widgets/home_scaffold.dart';
import 'package:flutteri18nl10n/src/presentation/widgets/notifications_card.dart';
import 'package:flutteri18nl10n/src/presentation/widgets/text_card.dart';
import 'package:flutteri18nl10n/src/repositories/preferences_repository_impl.dart';

import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesRepository = PreferencesRepositoryImpl();
  final preferencesBloc = PreferencesBloc(
    preferencesRepository: preferencesRepository,
    initialLocale: await preferencesRepository.locale
  );

  runApp(BlocProvider(
    create: (context) => preferencesBloc,
    child: App())
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: HomePage(),
          title: 'Flutter Intl Example',
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
            LocaleNamesLocalizationsDelegate()
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          locale: state.locale,
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firstName = 'Giancarlo';

  String _lastName = 'Code';

  int _notifications = 0;

  _resetNotifications() => setState(() => _notifications = 0);

  _incrementNotifications() => setState(() => _notifications++);

  _decrementNotifications() => setState(() {
    if (_notifications > 0) _notifications--;
  });

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      cards: <Widget>[
        LanguageCard(),
        TextCard(
          text: AppLocalizations.of(context).simpleText,
        ),
        TextCard(
          text: AppLocalizations.of(context).textWithPlaceholder(_firstName),
        ),
        TextCard(
          text: AppLocalizations.of(context).textWithPlaceholders(_firstName, _lastName),
        ),
        NotificationsCard(
          text: AppLocalizations.of(context).textWithPlural(_notifications),
          onReset: _resetNotifications,
          onDecrement: _decrementNotifications,
          onIncrement: _incrementNotifications,
        ),
      ],
    );
  }
}

class LanguageCard extends StatelessWidget {
  const LanguageCard({Key key}) : super(key: key);

  String _localizeLocale(BuildContext context, Locale locale) {
    if (locale == null) {
      return AppLocalizations.of(context).systemLanguage;
    } else {
      final localeString = LocaleNames.of(context).nameOf(locale.toString());
      return localeString[0].toUpperCase() + localeString.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesBloc = context.bloc<PreferencesBloc>();

    return ExpansionListCard<Locale>(
      title: AppLocalizations.of(context).language,
      subTitle: _localizeLocale(context, preferencesBloc.state.locale),
      leading: Icon(Icons.language, size: 48,),
      items: [
        null,
        ...AppLocalizations.delegate.supportedLocales
      ],
      itemBuilder: (locale) {
        return ExpansionCardItem(
          text: _localizeLocale(context, locale),
          onTap: () => preferencesBloc.add(ChangeLocale(locale))
        );
      },
    );
  }
}
