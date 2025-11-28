// lib/domain/entities/examination_extensions.dart
import 'examination.dart';

extension ExaminationView on Examination {
  String dateHumanReadable() {
    final d = dateTime.toLocal();
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)} ${months[d.month - 1]} ${d.year}, ${two(d.hour)}:${two(d.minute)}';
  }

  String summaryText() {
    final parts = <String>[];
    if (bloodPressure.isNotEmpty) parts.add('TD $bloodPressure');
    if (bloodGlucoseFasting != null) parts.add('GDP ${_trim(bloodGlucoseFasting)} mg/dL');
    if (bloodGlucoseRandom != null) parts.add('GDS ${_trim(bloodGlucoseRandom)} mg/dL');
    if (bloodGlucosePostprandial != null) parts.add('PP ${_trim(bloodGlucosePostprandial)} mg/dL');
    if (hba1c != null) parts.add('HbA1c ${_trim(hba1c)}%');
    if (hemoglobin != null) parts.add('Hb ${_trim(hemoglobin)} g/dL');
    return parts.join(' · ');
  }

  String _trim(num? n) {
    if (n == null) return '';
    final s = n.toString();
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
