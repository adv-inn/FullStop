import 'package:flutter_test/flutter_test.dart';
import 'package:fullstop/core/constants/album_filters.dart';

void main() {
  group('AlbumFilters', () {
    group('isDirty - should detect dirty albums', () {
      test('English: Live/Concert albums', () {
        expect(AlbumFilters.isDirty('Jay Chou World Tour 2004'), true);
        expect(AlbumFilters.isDirty('MTV Unplugged'), true);
        expect(AlbumFilters.isDirty('Live at Madison Square Garden'), true);
        expect(AlbumFilters.isDirty('The Concert 2023'), true);
        expect(AlbumFilters.isDirty('Acoustic Live Sessions'), true);
      });

      test('English: Best Of/Greatest Hits albums', () {
        expect(AlbumFilters.isDirty('Greatest Hits'), true);
        expect(AlbumFilters.isDirty('The Best of G.E.M.'), true);
        expect(AlbumFilters.isDirty('Best of Both Worlds'), true);
        expect(AlbumFilters.isDirty('The Essential Collection'), true);
        expect(AlbumFilters.isDirty('Anthology 1995-2005'), true);
      });

      test('Spanish: Live/Compilation albums', () {
        expect(AlbumFilters.isDirty('En Vivo desde Mexico'), true);
        expect(AlbumFilters.isDirty('Concierto en Madrid'), true);
        expect(AlbumFilters.isDirty('Exitos de Luis Miguel'), true);
        expect(AlbumFilters.isDirty('Lo Mejor de Shakira'), true);
        expect(AlbumFilters.isDirty('Colección de Oro'), true);
      });

      test('Chinese: Live/Compilation albums (Simplified)', () {
        expect(AlbumFilters.isDirty('七里香 演唱会'), true);
        expect(AlbumFilters.isDirty('地表最强现场'), true);
        expect(AlbumFilters.isDirty('周杰伦精选'), true);
        expect(AlbumFilters.isDirty('全记录 2000-2020'), true);
      });

      test('Chinese: Live/Compilation albums (Traditional)', () {
        expect(AlbumFilters.isDirty('七里香 演唱會'), true);
        expect(AlbumFilters.isDirty('周杰倫精選'), true);
      });

      test('Japanese: Live/Compilation albums', () {
        expect(AlbumFilters.isDirty('東京ドームライブ'), true);
        expect(AlbumFilters.isDirty('コンサート2023'), true);
        expect(AlbumFilters.isDirty('ベストアルバム'), true);
        expect(AlbumFilters.isDirty('コレクション'), true);
      });

      test('Korean: Live/Compilation albums', () {
        expect(AlbumFilters.isDirty('라이브 앨범'), true);
        expect(AlbumFilters.isDirty('콘서트 2023'), true);
        expect(AlbumFilters.isDirty('베스트 앨범'), true);
        expect(AlbumFilters.isDirty('히트곡 모음'), true);
      });

      test('Mixed language album names', () {
        expect(AlbumFilters.isDirty('地表最强 (Live)'), true);
        expect(AlbumFilters.isDirty('Fantasy World Tour'), true);
        expect(AlbumFilters.isDirty('G.E.M. X.X.X. Live'), true);
      });
    });

    group('isClean - should keep clean studio albums', () {
      test('English: Studio albums with potential false positives', () {
        // Critical test: "Alive" should NOT match "live" due to word boundary
        expect(AlbumFilters.isClean('Alive'), true);
        // "Oliver" contains "live" but should not match
        expect(AlbumFilters.isClean('Oliver'), true);
        // "Deliver" contains "live" but should not match
        expect(AlbumFilters.isClean('Deliver'), true);
        // "Best Life" should not match "best of"
        expect(AlbumFilters.isClean('Best Life'), true);
        // "Collection" as part of another word
        expect(AlbumFilters.isClean('Recollection of Youth'), true);
      });

      test('English: Normal studio albums', () {
        expect(AlbumFilters.isClean('Fantasy'), true);
        expect(AlbumFilters.isClean('Thriller'), true);
        expect(AlbumFilters.isClean('1989'), true);
        expect(AlbumFilters.isClean('After Hours'), true);
        expect(AlbumFilters.isClean('Dawn FM'), true);
      });

      test('Chinese: Normal studio albums', () {
        expect(AlbumFilters.isClean('七里香'), true);
        expect(AlbumFilters.isClean('范特西'), true);
        expect(AlbumFilters.isClean('叶惠美'), true);
        expect(AlbumFilters.isClean('我很忙'), true);
        expect(AlbumFilters.isClean('最伟大的作品'), true);
      });

      test('Japanese: Normal studio albums', () {
        expect(AlbumFilters.isClean('Fantôme'), true);
        expect(AlbumFilters.isClean('深海'), true);
        expect(AlbumFilters.isClean('HEART STATION'), true);
      });

      test('Korean: Normal studio albums', () {
        expect(AlbumFilters.isClean('MADE'), true);
        expect(AlbumFilters.isClean('WINGS'), true);
        expect(AlbumFilters.isClean('Map of the Soul: 7'), true);
      });

      test('Spanish: Normal studio albums', () {
        expect(AlbumFilters.isClean('Romance'), true);
        expect(AlbumFilters.isClean('Fijación Oral'), true);
        expect(AlbumFilters.isClean('Amar es Combatir'), true);
      });
    });

    group('Edge cases', () {
      test('Empty and whitespace strings', () {
        expect(AlbumFilters.isClean(''), true);
        expect(AlbumFilters.isClean('   '), true);
      });

      test('Case insensitivity', () {
        expect(AlbumFilters.isDirty('LIVE'), true);
        expect(AlbumFilters.isDirty('Live'), true);
        expect(AlbumFilters.isDirty('live'), true);
        expect(AlbumFilters.isDirty('GREATEST HITS'), true);
        expect(AlbumFilters.isDirty('greatest hits'), true);
      });

      test('Special characters in album names', () {
        expect(AlbumFilters.isClean('Lover (Deluxe)'), true);
        expect(AlbumFilters.isClean('1989 [Deluxe Edition]'), true);
        expect(AlbumFilters.isDirty('Live! [Deluxe]'), true);
      });

      test('Numbers and symbols', () {
        expect(AlbumFilters.isClean('4:44'), true);
        expect(AlbumFilters.isClean('÷ (Divide)'), true);
        expect(AlbumFilters.isClean('× (Multiply)'), true);
      });
    });
  });
}
