library http_verb_test.unit.resem.pl;

import 'package:test/test.dart';
import 'package:resem.pl/http.dart' show HttpVerb;

void main() {
  group('Unit', () {
    group('Http', () {
      group('HttpVerb', () {
        test('Instances are comparable with strings values of the enum keys',
            () {
          expect(HttpVerb.GET == 'GET', true,
              reason: 'HttpVerb.GET should be equal with the string "GET"');
          expect(HttpVerb.POST != 'GET', true,
              reason:
                  'HttpVerb.POST should not be equal with the string "GET"');
          expect(HttpVerb.PUT == 'DELETE', false,
              reason:
                  'HttpVerb.PUT should not be equal with the string "DELETE"');
        });

        test(
            'Instances accessed by enum keys should be same instance same as creating them through the HttpVerb.fromString constructor',
            () {
          expect(HttpVerb.GET, same(new HttpVerb.fromString('GET')));
          expect(HttpVerb.POST, same(new HttpVerb.fromString('POST')));
          expect(HttpVerb.DELETE, same(new HttpVerb.fromString('DELETE')));
        });

        test(
            'Creating non-existing instances via HttpVerb.fromString throws an UnsupportedError',
            () {
          expect(() => new HttpVerb.fromString('NON-EXISTING'),
              throwsUnsupportedError);
        });
      });
    });
  });
}
