import 'package:flutter_test/flutter_test.dart';
import 'package:oyun_blok_doldurma/oyun_blok_doldurma.dart';
import 'package:oyun_poliomino_yerlestirme/oyun_poliomino_yerlestirme.dart';
import 'package:studio_core/core/level_plan.dart';

void main() {
  final rules = PentoRules();
  final planner = LevelPlanner(gameId: rules.gameId, optionalMechanics: rules.optionalMechanics);

  test('12 beşli, 63 yön', () {
    expect(kPentominoes.length, 12);
    expect(kOrientations.length, 63);
  });

  test('bölümler dikdörtgeni beşlilerle eksiksiz döşer', () {
    for (final lv in [1, 25, 50, 99, 230, 777, 2500, 9999, 33333, 49999]) {
      final gl = rules.build(planner.spec(lv));
      expect(gl.validation.ok, isTrue, reason: 'bölüm $lv');
      expect(gl.attempts, lessThan(40), reason: 'bölüm $lv');
      final l = gl.puzzle;
      expect(l.pieces.length * 5, l.width * l.height);
      final g = FillGame(l);
      for (var i = 0; i < l.pieces.length; i++) {
        g.pieces[i] = l.pieces[i];
        expect(g.place(i, l.solution[i][0], l.solution[i][1]), isTrue);
      }
      expect(g.won, isTrue);
    }
  });

  test('kimlik doldurma oyunundan ayrı', () {
    expect(rules.gameId, isNot(blokDoldurmaId));
  });
}
