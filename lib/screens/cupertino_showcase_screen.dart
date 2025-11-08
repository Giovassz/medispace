import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoShowcaseScreen extends StatefulWidget {
  const CupertinoShowcaseScreen({super.key});

  @override
  State<CupertinoShowcaseScreen> createState() =>
      _CupertinoShowcaseScreenState();
}

class _CupertinoShowcaseScreenState extends State<CupertinoShowcaseScreen> {
  final TextEditingController _notesController = TextEditingController();
  final Map<int, Widget> _segments = const {
    0: Text('General'),
    1: Text('Cardiología'),
    2: Text('Pediatría'),
  };

  int _selectedSegment = 0;
  bool _notificationsEnabled = true;
  double _medicationDose = 1.0;
  DateTime _nextAppointment = DateTime.now().add(
    const Duration(days: 7, hours: 10),
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Experiencia iOS'),
        previousPageTitle: 'Ajustes',
        backgroundColor: Color(0xFFF9FBFF),
      ),
      child: SafeArea(
        top: false,
        child: CupertinoScrollbar(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _buildSectionHeader('Especialidades'),
              _buildSegmentedControl(),
              const SizedBox(height: 24),
              _buildSectionHeader('Recordatorios de Salud'),
              _buildSwitchTile(),
              const SizedBox(height: 24),
              _buildSectionHeader('Ajustes Personalizados'),
              _buildSliderCard(),
              const SizedBox(height: 24),
              _buildNotesField(),
              const SizedBox(height: 24),
              _buildDatePickerButton(context),
              const SizedBox(height: 16),
              _buildActionSheetButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF25324A),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona la especialidad para ver recomendaciones personalizadas.',
            style: TextStyle(fontSize: 14, color: Color(0xFF697386)),
          ),
          const SizedBox(height: 16),
          CupertinoSegmentedControl<int>(
            children: _segments,
            groupValue: _selectedSegment,
            selectedColor: const Color(0xFF0FB0C0),
            borderColor: const Color(0xFF0FB0C0),
            pressedColor: const Color(0xFFB5E7ED),
            onValueChanged: (value) {
              setState(() {
                _selectedSegment = value;
              });
            },
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _getSegmentDescription(_selectedSegment),
              key: ValueKey(_selectedSegment),
              style: const TextStyle(fontSize: 15, color: Color(0xFF25324A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones de seguimiento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF25324A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Activa recordatorios diarios para la toma de medicamentos.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF697386)),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _notificationsEnabled,
            activeColor: const Color(0xFF0FB0C0),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.drop, color: Color(0xFF0FB0C0)),
              const SizedBox(width: 8),
              const Text(
                'Dosis sugerida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF25324A),
                ),
              ),
              const Spacer(),
              Text(
                '${_medicationDose.toStringAsFixed(1)} ml',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0FB0C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CupertinoSlider(
            value: _medicationDose,
            min: 0.5,
            max: 5,
            divisions: 9,
            activeColor: const Color(0xFF0FB0C0),
            thumbColor: const Color(0xFF0EA5E9),
            onChanged: (value) {
              setState(() {
                _medicationDose = value;
              });
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajusta la dosis diaria según la recomendación médica.',
            style: TextStyle(fontSize: 14, color: Color(0xFF697386)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notas para el equipo médico',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF25324A),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _notesController,
            placeholder: 'Describe síntomas o cambios recientes...',
            maxLines: 4,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoButton.filled(
            onPressed: () {
              FocusScope.of(context).unfocus();
              final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
              if (scaffoldMessenger != null) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      _notesController.text.isEmpty
                          ? 'Agrega una nota para el personal médico.'
                          : 'Notas guardadas temporalmente en tu dispositivo.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Guardar nota'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    final formattedDate =
        '${_nextAppointment.day.toString().padLeft(2, '0')}/${_nextAppointment.month.toString().padLeft(2, '0')}/${_nextAppointment.year}';

    return CupertinoButton(
      color: const Color(0xFF0FB0C0),
      borderRadius: BorderRadius.circular(24),
      onPressed: () => _showDatePicker(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.calendar_today, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Reprogramar próxima cita ($formattedDate)',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSheetButton(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      onPressed: () => _showActionSheet(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.info_circle, color: Color(0xFF0FB0C0)),
          SizedBox(width: 8),
          Text(
            'Ver recomendaciones rápidas',
            style: TextStyle(color: Color(0xFF0FB0C0)),
          ),
        ],
      ),
    );
  }

  String _getSegmentDescription(int segment) {
    switch (segment) {
      case 1:
        return 'Cardiología: Monitorea tu presión arterial y mantén una dieta balanceada baja en sodio.';
      case 2:
        return 'Pediatría: Lleva un registro de vacunas y síntomas para cada consulta pediátrica.';
      default:
        return 'Medicina General: Programa tus chequeos preventivos y actualiza tus antecedentes médicos.';
    }
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => Container(
        height: 320,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const Text(
                    'Selecciona nueva fecha',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: _nextAppointment,
                minimumDate: DateTime.now(),
                onDateTimeChanged: (date) {
                  setState(() {
                    _nextAppointment = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => CupertinoActionSheet(
        title: const Text('Recomendaciones'),
        message: Text(
          _selectedSegment == 1
              ? 'Mantén un registro diario de actividad física y toma medidas de presión arterial en casa.'
              : _selectedSegment == 2
              ? 'Registra la temperatura y el descanso nocturno de tu pequeño para compartirlo en la siguiente visita.'
              : 'Agrega notas sobre síntomas recurrentes y actualiza tu lista de medicamentos.',
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ),
    );
  }
}
