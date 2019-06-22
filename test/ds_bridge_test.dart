import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ds_bridge/ds_bridge.dart';

void main() {
  const MethodChannel channel = MethodChannel('ds_bridge');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DsBridge.platformVersion, '42');
  });
}
