import 'package:flutter_test/flutter_test.dart';
import 'package:levelup/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@tld'), isNotNull);
    });

    test('accepts a well-formed address, trimming whitespace', () {
      expect(Validators.email('  user@example.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty input', () {
      expect(Validators.password(''), isNotNull);
    });

    test('rejects passwords shorter than the minimum length', () {
      expect(Validators.password('short'), isNotNull);
    });

    test('accepts a password meeting the minimum length', () {
      expect(Validators.password('a-long-enough-password'), isNull);
    });
  });

  group('Validators.fullName', () {
    test('rejects empty or single-character input', () {
      expect(Validators.fullName(''), isNotNull);
      expect(Validators.fullName('A'), isNotNull);
    });

    test('accepts a real name', () {
      expect(Validators.fullName('Ali Yarmohammadi'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects a mismatch', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
    });

    test('accepts a match', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });
}
