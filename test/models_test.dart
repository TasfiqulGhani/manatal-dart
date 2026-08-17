import 'package:manatal/manatal.dart';
import 'package:test/test.dart';

void main() {
  test('supports property and map access', () {
    final job = ManatalObject({
      'id': 42,
      'position_name': 'pyp',
      'organization': {'id': 1, 'name': 'Acme'},
    });

    expect(job['id'], 42);
    expect(job['position_name'], 'pyp');
    expect((job['organization'] as ManatalObject)['name'], 'Acme');
    expect((job['organization'] as ManatalObject)['id'], 1);

    // Property access via noSuchMethod at runtime.
    expect((job as dynamic).id, 42);
    expect((job as dynamic).position_name, 'pyp');
    expect((job as dynamic).organization.name, 'Acme');
  });

  test('missing property throws NoSuchMethodError', () {
    final job = ManatalObject({'id': 1});
    expect(() => (job as dynamic).missing, throwsA(isA<NoSuchMethodError>()));
  });
}
