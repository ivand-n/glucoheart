import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/themes/app_theme.dart';
import '../../../providers/examination_provider.dart';
import '../../../../domain/entities/examination.dart';

class ExaminationForm extends ConsumerStatefulWidget {
  /// null => Create, !null => Edit
  final Examination? initial;
  /// dipanggil saat sukses; kalau null, form akan `Navigator.pop(context, result)`
  final ValueChanged<Examination>? onSuccess;

  const ExaminationForm({super.key, this.initial, this.onSuccess});

  @override
  ConsumerState<ExaminationForm> createState() => _ExaminationFormState();
}

class _ExaminationFormState extends ConsumerState<ExaminationForm> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidate = AutovalidateMode.onUserInteraction;

  final _gdpCtrl = TextEditingController();
  final _gdsCtrl = TextEditingController();
  final _ppCtrl = TextEditingController();
  final _hba1cCtrl = TextEditingController();
  final _hbCtrl = TextEditingController();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _picked = DateTime.now();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    if (e != null) {
      String _fmt(num? n) => n == null ? '' : n.toString();
      if (e.bloodGlucoseFasting != null) _gdpCtrl.text = _fmt(e.bloodGlucoseFasting);
      if (e.bloodGlucoseRandom != null) _gdsCtrl.text = _fmt(e.bloodGlucoseRandom);
      if (e.bloodGlucosePostprandial != null) _ppCtrl.text = _fmt(e.bloodGlucosePostprandial);
      if (e.hba1c != null) _hba1cCtrl.text = _fmt(e.hba1c);
      if (e.hemoglobin != null) _hbCtrl.text = _fmt(e.hemoglobin);
      if (e.bloodPressure.isNotEmpty) {
        final sp = e.bloodPressure.split('/');
        if (sp.length == 2) {
          _sysCtrl.text = sp[0];
          _diaCtrl.text = sp[1];
        }
      }
      if (e.notes != null) _notesCtrl.text = e.notes!;
      _picked = e.dateTime;
    }
  }

  @override
  void dispose() {
    _gdpCtrl.dispose();
    _gdsCtrl.dispose();
    _ppCtrl.dispose();
    _hba1cCtrl.dispose();
    _hbCtrl.dispose();
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double? _toDouble(String s) => s.trim().isEmpty ? null : double.tryParse(s.replaceAll(',', '.'));
  int? _toInt(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());

  static const _rngGula = (min: 40.0, max: 600.0);
  static const _rngGulaPuasa = (min: 40.0, max: 500.0);
  static const _rngHbA1c = (min: 3.0, max: 20.0);
  static const _rngHb = (min: 5.0, max: 22.0);
  static const _rngSys = (min: 70, max: 250);
  static const _rngDia = (min: 40, max: 150);

  String? _optNum(String? v, double min, double max, String label) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    final n = _toDouble(t);
    if (n == null) return '$label harus berupa angka';
    if (n < min || n > max) return '$label harus $min–$max';
    return null;
  }

  String? _reqInt(String? v, int min, int max, String label) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$label wajib diisi';
    final n = _toInt(t);
    if (n == null) return '$label harus berupa angka bulat';
    if (n < min || n > max) return '$label harus $min–$max';
    return null;
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _picked,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_picked),
    );
    setState(() {
      _picked = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
    });
  }

  InputDecoration _dec({
    required String label,
    String? hint,
    String? unit,
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      suffixText: unit,
      filled: true,
      fillColor: AppColors.scaffoldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentColor, width: 1.2),
        borderRadius: AppBorderRadius.small,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.8),
        borderRadius: AppBorderRadius.small,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 1.6),
        borderRadius: AppBorderRadius.small,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.error, width: 1.8),
        borderRadius: AppBorderRadius.small,
      ),
    );
  }

  Widget _numField({
    required TextEditingController c,
    required String label,
    String? hint,
    String? unit,
    String? helper,
    String? Function(String?)? validator,
    List<TextInputFormatter>? formatters,
    TextInputAction action = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    return StatefulBuilder(
      builder: (context, setSB) {
        bool validNow() =>
            validator != null && validator(c.text) == null && c.text.isNotEmpty;
        return Focus(
          onFocusChange: (_) => setSB(() {}),
          child: TextFormField(
            controller: c,
            autovalidateMode: _autovalidate,
            decoration: _dec(label: label, hint: hint, unit: unit, helper: helper)
                .copyWith(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: validNow() ? AppColors.success : AppColors.accentColor,
                  width: 1.2,
                ),
                borderRadius: AppBorderRadius.small,
              ),
            ),
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: formatters ??
                [FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]'))],
            validator: validator,
            textInputAction: action,
            onFieldSubmitted: onSubmitted,
            onChanged: (_) => setSB(() {}),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidate = AutovalidateMode.always);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);

    final sys = _toInt(_sysCtrl.text)!;
    final dia = _toInt(_diaCtrl.text)!;

    final payload = Examination(
      id: widget.initial?.id ?? '',
      bloodGlucoseRandom: _toDouble(_gdsCtrl.text),
      bloodGlucoseFasting: _toDouble(_gdpCtrl.text),
      hba1c: _toDouble(_hba1cCtrl.text),
      hemoglobin: _toDouble(_hbCtrl.text),
      bloodGlucosePostprandial: _toDouble(_ppCtrl.text),
      bloodPressure: '$sys/$dia',
      dateTime: _picked,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final notifier = ref.read(examinationNotifierProvider.notifier);
    final editing = widget.initial != null;

    try {
      final Examination result = editing
          ? await notifier.updateExamination(payload)
          : await notifier.addExamination(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editing
                ? 'Data berhasil diperbarui'
                : 'Data berhasil disimpan'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }

      // kirim balik object terbaru ke caller
      if (widget.onSuccess != null) {
        widget.onSuccess!(result);
      } else {
        // fallback: close page dengan result
        // ignore: use_build_context_synchronously
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;

    return Form(
      key: _formKey,
      autovalidateMode: _autovalidate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Waktu Pemeriksaan'),
          InkWell(
            onTap: _busy ? null : _pickDateTime,
            borderRadius: AppBorderRadius.small,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: AppBorderRadius.small,
                border: Border.all(color: AppColors.accentColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _picked.toLocal().toString(),
                      style:
                      const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const Icon(Icons.edit_calendar_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _section('Gula Darah'),
          _numField(
            c: _gdpCtrl,
            label: 'GDP (Puasa)',
            hint: 'mg/dL',
            unit: 'mg/dL',
            helper:
            'Range valid ${_rngGulaPuasa.min.toStringAsFixed(0)}–${_rngGulaPuasa.max.toStringAsFixed(0)}',
            validator: (v) =>
                _optNum(v, _rngGulaPuasa.min, _rngGulaPuasa.max, 'GDP'),
          ),
          const SizedBox(height: 12),
          _numField(
            c: _gdsCtrl,
            label: 'GDS (Sewaktu)',
            hint: 'mg/dL',
            unit: 'mg/dL',
            helper:
            'Range valid ${_rngGula.min.toStringAsFixed(0)}–${_rngGula.max.toStringAsFixed(0)}',
            validator: (v) =>
                _optNum(v, _rngGula.min, _rngGula.max, 'GDS'),
          ),
          const SizedBox(height: 12),
          _numField(
            c: _ppCtrl,
            label: 'Gula Darah 2 Jam PP',
            hint: 'mg/dL',
            unit: 'mg/dL',
            helper:
            'Range valid ${_rngGula.min.toStringAsFixed(0)}–${_rngGula.max.toStringAsFixed(0)}',
            validator: (v) => _optNum(
                v, _rngGula.min, _rngGula.max, 'Gula darah 2 jam PP'),
          ),
          const SizedBox(height: 20),

          _section('HbA1c & Hemoglobin'),
          _numField(
            c: _hba1cCtrl,
            label: 'HbA1c',
            hint: '%',
            unit: '%',
            helper: 'Range valid ${_rngHbA1c.min}–${_rngHbA1c.max}%',
            validator: (v) =>
                _optNum(v, _rngHbA1c.min, _rngHbA1c.max, 'HbA1c'),
          ),
          const SizedBox(height: 12),
          _numField(
            c: _hbCtrl,
            label: 'Hemoglobin',
            hint: 'g/dL',
            unit: 'g/dL',
            helper: 'Range valid ${_rngHb.min}–${_rngHb.max} g/dL',
            validator: (v) =>
                _optNum(v, _rngHb.min, _rngHb.max, 'Hemoglobin'),
          ),
          const SizedBox(height: 20),

          _section('Tekanan Darah'),
          Row(
            children: [
              Expanded(
                child: _numField(
                  c: _sysCtrl,
                  label: 'Sistol',
                  hint: 'mmHg',
                  unit: 'mmHg',
                  helper: 'Wajib ${_rngSys.min}–${_rngSys.max}',
                  validator: (v) =>
                      _reqInt(v, _rngSys.min, _rngSys.max, 'Sistol'),
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numField(
                  c: _diaCtrl,
                  label: 'Diastol',
                  hint: 'mmHg',
                  unit: 'mmHg',
                  helper: 'Wajib ${_rngDia.min}–${_rngDia.max}',
                  validator: (v) =>
                      _reqInt(v, _rngDia.min, _rngDia.max, 'Diastol'),
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  action: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_busy) _submit();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _section('Catatan (opsional)'),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            autovalidateMode: _autovalidate,
            decoration: InputDecoration(
              hintText: 'Tulis catatan...',
              border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.small),
              filled: true,
              fillColor: AppColors.scaffoldBackground,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _submit,
              icon: Icon(widget.initial != null
                  ? Icons.save_as_outlined
                  : Icons.save_outlined),
              label: Text(_busy
                  ? (widget.initial != null
                  ? 'Menyimpan Perubahan...'
                  : 'Menyimpan...')
                  : (widget.initial != null
                  ? 'Simpan Perubahan'
                  : 'Simpan')),
            ),
          ),
        ],
      ),
    );
  }
}
