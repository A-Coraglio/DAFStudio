import 'package:flutter_test/flutter_test.dart';
import 'package:gohan/core/format/dates.dart';
import 'package:gohan/core/format/labels.dart';

void main() {
  group('labels', () {
    test('levelLabel traduce los niveles y banca null', () {
      expect(levelLabel('beginner'), 'Principiante');
      expect(levelLabel('intermediate'), 'Intermedio');
      expect(levelLabel('advanced'), 'Avanzado');
      expect(levelLabel(null), 'Sin definir');
      expect(levelLabel('otro'), 'otro'); // passthrough de valores nuevos
    });

    test('modeLabel', () {
      expect(modeLabel('casual'), 'Casual');
      expect(modeLabel('competitive'), 'Competitivo');
    });

    test('tournamentStatusLabel y lessonStatusLabel', () {
      expect(tournamentStatusLabel('upcoming'), 'Inscripción abierta');
      expect(tournamentStatusLabel('ongoing'), 'En juego');
      expect(tournamentStatusLabel('finished'), 'Finalizado');
      expect(lessonStatusLabel('confirmed'), 'Confirmada');
      expect(lessonStatusLabel('cancelled'), 'Cancelada');
    });

    test('distanceLabel: metros, coma decimal y redondeo', () {
      expect(distanceLabel(null), isNull);
      expect(distanceLabel(0.4), 'a 400 m');
      expect(distanceLabel(2.34), 'a 2,3 km');
      expect(distanceLabel(15.7), 'a 16 km');
    });

    test('shortDate', () {
      expect(shortDate(DateTime(2026, 7, 21)), '21 jul');
      expect(shortDate(DateTime(2026, 1, 3)), '3 ene');
    });
  });

  group('dates', () {
    test('formatSchedule sin fecha', () {
      expect(formatSchedule(null), 'Sin fecha');
    });

    test('formatSchedule hoy dice "Hoy HH:MM"', () {
      final now = DateTime.now();
      final at = DateTime(now.year, now.month, now.day, 18, 5);
      expect(formatSchedule(at), 'Hoy 18:05');
    });

    test('formatFullDate con ceros', () {
      expect(formatFullDate(DateTime(2026, 4, 9)), '09/04/2026');
    });

    test('formatHour', () {
      expect(formatHour(DateTime(2026, 7, 21, 8, 5)), '08:05');
    });

    test('formatCountdown: null sin fecha o ya empezado', () {
      expect(formatCountdown(null), isNull);
      expect(
        formatCountdown(DateTime.now().subtract(const Duration(hours: 1))),
        isNull,
      );
    });

    test('formatCountdown futuro cercano', () {
      final at = DateTime.now().add(const Duration(minutes: 30));
      expect(formatCountdown(at), startsWith('Empieza en'));
    });
  });
}
