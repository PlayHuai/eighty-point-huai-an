import 'package:eighty_point_huai_an/src/api/request_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('request IDs are unique UUID v4 values', () {
    final first = createRequestId();
    final second = createRequestId();

    expect(
      first,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(second, isNot(first));
  });
}
