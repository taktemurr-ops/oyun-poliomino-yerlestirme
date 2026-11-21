/// Beşli Yerleştirme: dikdörtgeni beşli parçalarla eksiksiz doldur.
/// Blok Doldurma motorunu ve ekranını kullanır.
library;

import 'package:flutter/material.dart';
import 'package:oyun_blok_doldurma/oyun_blok_doldurma.dart';
import 'package:studio_core/app/game_api.dart';

import 'src/pento.dart';

export 'src/pento.dart';

final besliConfig = GameConfig(
  gameId: besliId,
  title: const ['Beşli Yerleştirme', 'Five-Block Fit', 'Fünfer-Puzzle', 'Encaje de Cinco', 'Casse-tête à Cinq'],
  tagline: const [
    'Beşli parçalarla dikdörtgeni doldur!',
    'Fill the rectangle with five-cell pieces!',
    'Fülle das Rechteck mit Fünfer-Teilen!',
    '¡Llena el rectángulo con piezas de cinco!',
    'Remplissez le rectangle avec des pièces de cinq !',
  ],
  seedColor: const Color(0xFF43A047),
  icon: Icons.dashboard_rounded,
  rules: PentoRules(),
  buildPlay: (ctx) => FillView(ctx: ctx),
  tutorial: const [
    TutorialStep(Icons.pan_tool_alt, [
      'Her parça beş kareden oluşur. Hepsini dikdörtgene boşluk kalmadan yerleştir.',
      'Every piece has five cells. Fit them all into the rectangle with no gaps.',
      'Jedes Teil hat fünf Felder. Fülle das Rechteck lückenlos.',
      'Cada pieza tiene cinco casillas. Llena el rectángulo sin huecos.',
      'Chaque pièce a cinq cases. Remplissez le rectangle sans trou.',
    ]),
    TutorialStep(Icons.rotate_right, [
      'Seçili parçaya bir daha dokun ya da basılı tut: döner.',
      'Tap the selected piece again or long-press to rotate it.',
      'Tippe das gewählte Teil erneut an oder halte es: es dreht sich.',
      'Toca otra vez la pieza o mantenla pulsada para girarla.',
      'Touchez à nouveau la pièce ou appuyez longuement pour la tourner.',
    ]),
  ],
);
