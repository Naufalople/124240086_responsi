import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsi/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MainApp(
      isLoggedIn: false,
      currentUser: '',
    ));
    await tester.pump();
    expect(find.text('SpaceNews Explorer'), findsWidgets);
  });
}
