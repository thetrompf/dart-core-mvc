library test.resem.pl;

import 'package:resem.pl/resem.pl.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';

@TestOn("vm")

void main() {
  group("Simple requests", () {
    Application app = null;
    HttpClient client = null;

    setUp(() async {
      app = new Application(router: null, logger: new TtyLogger(group: 'test', groupColor: AnsiPen.green), port: 3331);
      client = new HttpClient();
      await app.start();
    });

    test("valid requests returns HttpStatus.OK", () async {
      var req = await client.getUrl(Uri.parse('http://localhost:3331'));
      var res = await req.close();
      expect(res.statusCode, HttpStatus.OK, reason: 'valid http request to root should return status code 200 (HttpStatus.OK)');
    }, timeout: );

    test("requests to non-existing resource returns HttpStatus.NOT_FOUND", () async {
      var req = await client.getUrl(Uri.parse('http://localhost:3331/non-existing-resources'));
      var res = await req.close();
      expect(res.statusCode, HttpStatus.NOT_FOUND, reason: 'requesting non-exsting resources should return status code 404 (HttpStatus.NOT_FOUND)');
    });

    tearDown(() async {
      await app.stop();
      app = null;
      client = null;
    });
  });
}
