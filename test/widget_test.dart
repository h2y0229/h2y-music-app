import 'package:flutter_test/flutter_test.dart';
import 'package:h2y_music_app/main.dart';

void main() {
  testWidgets('h2y Music App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const H2yMusicApp());
    expect(find.text('h2y Music Player'), findsOneWidget);
  });
}
