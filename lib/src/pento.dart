import 'package:oyun_blok_doldurma/oyun_blok_doldurma.dart';
import 'package:studio_core/core/game_rules.dart';
import 'package:studio_core/core/level_plan.dart';
import 'package:studio_core/core/rng.dart';

const besliId = 'oyun-poliomino-yerlestirme';

/// 12 serbest beşli (pentomino) şekli.
const List<List<List<int>>> kPentominoes = [
  [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0]], // I
  [[0, 0], [0, 1], [0, 2], [0, 3], [1, 3]], // L
  [[0, 0], [0, 1], [0, 2], [1, 2], [1, 3]], // N
  [[0, 0], [1, 0], [0, 1], [1, 1], [0, 2]], // P
  [[0, 0], [1, 0], [2, 0], [1, 1], [1, 2]], // T
  [[0, 0], [2, 0], [0, 1], [1, 1], [2, 1]], // U
  [[0, 0], [0, 1], [0, 2], [1, 2], [2, 2]], // V
  [[0, 0], [0, 1], [1, 1], [1, 2], [2, 2]], // W
  [[1, 0], [0, 1], [1, 1], [2, 1], [1, 2]], // X
  [[1, 0], [0, 1], [1, 1], [1, 2], [1, 3]], // Y
  [[0, 0], [1, 0], [1, 1], [1, 2], [2, 2]], // Z
  [[1, 0], [2, 0], [0, 1], [1, 1], [1, 2]], // F
];

/// Bütün yönler (döndürme + ayna), tekil; her biri normalize.
final List<List<List<int>>> kOrientations = () {
  final seen = <String>{};
  final out = <List<List<int>>>[];
  for (final p in kPentominoes) {
    var cur = p;
    for (var m = 0; m < 2; m++) {
      for (var r = 0; r < 4; r++) {
        final n = FillPiece.normalize(cur);
        if (seen.add(n.map((c) => '${c[0]},${c[1]}').join(';'))) out.add(n);
        cur = [for (final c in cur) [-c[1], c[0]]];
      }
      cur = [for (final c in p) [-c[0], c[1]]];
    }
  }
  return out;
}();

(int, int) boardFor(int d) => switch (d) {
      1 || 2 => (5, 4),
      3 || 4 => (5, 5),
      5 => (6, 5),
      6 => (5, 7),
      7 || 8 => (8, 5),
      _ => (10, 6),
    };

/// Dikdörtgeni rastgele beşlilerle döşer; (parçalar, sol üst konumlar).
(List<List<List<int>>>, List<List<int>>)? tile(int w, int h, SeededRandom r, {int budget = 40000}) {
  final grid = List<int>.filled(w * h, -1);
  final pieces = <List<List<int>>>[];
  final at = <List<int>>[];
  var nodes = 0;
  final order = List<int>.generate(kOrientations.length, (i) => i);

  bool rec() {
    if (++nodes > budget) return false;
    final first = grid.indexOf(-1);
    if (first < 0) return true;
    final fx = first % w, fy = first ~/ w;
    final ord = List<int>.of(order);
    r.shuffle(ord);
    for (final oi in ord) {
      final o = kOrientations[oi];
      // İlk kare (en üst satırın en solu) boş hücreye denk gelsin.
      final ox = fx - o[0][0], oy = fy - o[0][1];
      var ok = true;
      for (final c in o) {
        final x = ox + c[0], y = oy + c[1];
        if (x < 0 || y < 0 || x >= w || y >= h || grid[y * w + x] >= 0) {
          ok = false;
          break;
        }
      }
      if (!ok) continue;
      final id = pieces.length;
      for (final c in o) {
        grid[(oy + c[1]) * w + ox + c[0]] = id;
      }
      pieces.add(o);
      at.add([ox, oy]);
      if (rec()) return true;
      pieces.removeLast();
      at.removeLast();
      for (final c in o) {
        grid[(oy + c[1]) * w + ox + c[0]] = -1;
      }
    }
    return false;
  }

  return rec() ? (pieces, at) : null;
}

FillLevel generatePentoLevel(LevelSpec spec) {
  final r = SeededRandom(mixSeed([spec.seed, 5555]));
  final d = spec.difficulty.clamp(1, 10);
  final (w, h) = boardFor(d);
  final t = tile(w, h, r);
  if (t == null) {
    return FillLevel(width: w, height: h, mask: List.filled(w * h, true), pieces: const [], solution: const [], turns: const [], difficulty: d, seed: spec.seed);
  }
  final (shapes, at) = t;
  final perm = List<int>.generate(shapes.length, (i) => i);
  r.shuffle(perm);
  return FillLevel(
    width: w,
    height: h,
    mask: List.filled(w * h, true),
    pieces: [for (final i in perm) FillPiece(shapes[i], 1 + i % 8)],
    solution: [for (final i in perm) at[i]],
    turns: [for (final _ in perm) d >= 3 ? r.nextInt(4) : 0],
    difficulty: d,
    seed: spec.seed,
  );
}

class PentoRules extends FillRules {
  @override
  String get gameId => besliId;

  @override
  FillLevel generate(LevelSpec spec) => generatePentoLevel(spec);

  @override
  Validation validate(FillLevel level, LevelSpec spec) {
    if (level.pieces.isEmpty) return const Validation.fail('tiling failed');
    if (level.pieces.any((p) => p.size != 5)) return const Validation.fail('not a pentomino');
    return super.validate(level, spec);
  }
}
