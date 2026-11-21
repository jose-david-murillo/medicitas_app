import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../database/db_helper.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../widgets/responsive_content.dart';
import '../widgets/section_header.dart';
import '../widgets/info_banner.dart';

class AgendarScreen extends StatefulWidget {
  const AgendarScreen({super.key});
  @override
  State<AgendarScreen> createState() => _AgendarScreenState();
}

class _AgendarScreenState extends State<AgendarScreen> {
  int paso = 1; // 1: Servicio, 2: Fecha y hora, 3: Confirmar
  String? sedeSeleccionada;
  String? especialidadId;
  Profesional? profesionalSel;
  String diaSel = '2026-11-02';
  String? horaSel;
  String? _error;
  final dias = [
    '2026-11-02',
    '2026-11-03',
    '2026-11-04',
    '2026-11-05',
    '2026-11-06',
  ];

  @override
  void initState() {
    super.initState();
    sedeSeleccionada = MockData.sedes.first.nombre;
    especialidadId = MockData.especialidades.first.id;
    profesionalSel = MockData.profesionales.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar cita'),
        leading: IconButton(
          tooltip: 'Volver al inicio',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  label: 'Paso $paso de 3: ${_tituloPaso()}',
                  child: ExcludeSemantics(child: _Stepper(paso: paso)),
                ),
                const SizedBox(height: 18),
                if (paso == 1) _buildPaso1(),
                if (paso == 2) _buildPaso2(),
                if (paso == 3) _buildPaso3(),
                const SizedBox(height: 18),
                if (_error != null)
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE57373)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 18,
                            color: Color(0xFFB3261E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB3261E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Row(
                  children: [
                    if (paso > 1)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            paso--;
                            _error = null;
                          }),
                          child: const Text('Atrás'),
                        ),
                      ),
                    if (paso > 1) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _continuar,
                        child: Text(paso == 3 ? 'Confirmar cita' : 'Continuar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tituloPaso() {
    if (paso == 1) return 'Servicio';
    if (paso == 2) return 'Fecha y hora';
    return 'Confirmar';
  }

  Widget _buildPaso1() {
    final profsFiltrados = MockData.profesionales
        .where((p) => p.especialidadId == especialidadId)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Sede'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: sedeSeleccionada,
          items: MockData.sedes
              .map(
                (s) => DropdownMenuItem(value: s.nombre, child: Text(s.nombre)),
              )
              .toList(),
          onChanged: (v) => setState(() {
            sedeSeleccionada = v;
            _error = null;
          }),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Especialidad'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: especialidadId,
          items: MockData.especialidades
              .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)))
              .toList(),
          onChanged: (v) {
            setState(() {
              especialidadId = v;
              _error = null;
              final filtrados = MockData.profesionales
                  .where((p) => p.especialidadId == v)
                  .toList();
              profesionalSel = filtrados.isNotEmpty ? filtrados.first : null;
            });
          },
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Profesional'),
        const SizedBox(height: 6),
        RadioGroup<Profesional>(
          groupValue: profesionalSel,
          onChanged: (v) => setState(() {
            profesionalSel = v;
            _error = null;
          }),
          child: Column(
            children: profsFiltrados
                .map(
                  (p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: profesionalSel == p
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: profesionalSel == p ? 1.5 : 1,
                      ),
                    ),
                    child: RadioListTile<Profesional>(
                      value: p,
                      title: Text(
                        p.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        p.sede,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                      secondary: CircleAvatar(
                        backgroundColor: const Color(0xFFE6F0F2),
                        child: Text(
                          p.avatar,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      activeColor: AppColors.primary,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        const InfoBanner(
          text:
              'RF-03 Consulta sedes y especialidades • RF-04 Consulta profesionales',
          icon: Icons.verified_outlined,
        ),
      ],
    );
  }

  Widget _buildPaso2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(child: Text(profesionalSel?.avatar ?? 'LG')),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profesionalSel?.nombre ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    sedeSeleccionada ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    MockData.especialidades
                        .firstWhere((e) => e.id == especialidadId)
                        .nombre,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _mesTitulo(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const Text(
              '5 días hábiles',
              style: TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dias.map((d) {
            final day = int.parse(d.split('-').last);
            final sel = d == diaSel;
            return Semantics(
              button: true,
              selected: sel,
              label:
                  '${_diaTexto(d)}, ${sel ? "seleccionado" : "no seleccionado"}',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => setState(() {
                  diaSel = d;
                  horaSel = null;
                  _error = null;
                }),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: sel ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: sel ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dias.map((d) {
            const abbr = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
            final fecha = DateTime.parse(d);
            return SizedBox(
              width: 44,
              child: Text(
                abbr[fecha.weekday - 1],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Horarios disponibles',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (MockData.horariosPorDia[diaSel] ?? []).map((slot) {
            final sel = horaSel == slot.hora;
            return ChoiceChip(
              label: Text(
                slot.hora,
                style: TextStyle(
                  fontSize: 12,
                  color: sel ? Colors.white : AppColors.textDark,
                ),
              ),
              selected: sel,
              onSelected: slot.disponible
                  ? (v) => setState(() {
                      horaSel = v ? slot.hora : null;
                      _error = null;
                    })
                  : null,
              selectedColor: AppColors.primary,
              backgroundColor: slot.disponible
                  ? Colors.white
                  : Colors.grey.shade200,
              side: BorderSide(
                color: sel ? AppColors.primary : Colors.grey.shade300,
              ),
              disabledColor: Colors.grey.shade200,
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        if (horaSel != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.teal, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selección: ${_diaTexto(diaSel)} • $horaSel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        const InfoBanner(
          text: 'RF-05 Consulta disponibilidad (solo fechas/horarios vigentes)',
          bgColor: Color(0xFFE3F2FD),
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildPaso3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.verified, color: AppColors.teal, size: 56),
        const SizedBox(height: 10),
        const Text(
          'Resumen de tu cita',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _row(
                  'Especialidad',
                  MockData.especialidades
                      .firstWhere((e) => e.id == especialidadId)
                      .nombre,
                ),
                _row('Profesional', profesionalSel?.nombre ?? ''),
                _row('Sede', sedeSeleccionada ?? ''),
                _row('Fecha', diaSel),
                _row('Hora', horaSel ?? ''),
                const Divider(),
                _row('Estado', 'Por confirmar', bold: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const InfoBanner(
          text:
              'RF-06 Agendamiento: al confirmar se crea la cita, bloquea cupo y entrega resumen',
          bgColor: Color(0xFFFFF8E1),
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _row(String k, String v, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: const TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
        Text(
          v,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  bool _puedeContinuar() {
    if (paso == 1) {
      return sedeSeleccionada != null &&
          especialidadId != null &&
          profesionalSel != null;
    }
    if (paso == 2) return horaSel != null;
    return true;
  }

  void _continuar() {
    if (!_puedeContinuar()) {
      setState(
        () => _error = paso == 1
            ? 'Selecciona sede, especialidad y profesional para continuar.'
            : 'Selecciona un horario disponible para continuar.',
      );
      return;
    }
    setState(() => _error = null);
    if (paso < 3) {
      setState(() => paso++);
    } else {
      _confirmarCita();
    }
  }

  String _diaTexto(String iso) {
    final fecha = DateTime.parse(iso);
    const semana = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${semana[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]}';
  }

  String _mesTitulo() {
    final fecha = DateTime.parse(dias.first);
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${meses[fecha.month - 1]} de ${fecha.year}';
  }

  void _confirmarCita() {
    if (horaSel == null) {
      setState(
        () => _error = 'Selecciona un horario disponible para continuar.',
      );
      return;
    }
    final nueva = Cita(
      id: 'CIT-2026-${(MockData.citas.length + 1).toString().padLeft(3, '0')}',
      especialidad: MockData.especialidades
          .firstWhere((e) => e.id == especialidadId)
          .nombre,
      profesional: profesionalSel!.nombre,
      sede: sedeSeleccionada!,
      fechaHora: DateTime.parse('$diaSel ${_to24(horaSel!)}'),
      estado: 'Confirmada',
    );

    // Bloquear cupo de inmediato
    MockData.bloquearCupo(diaSel, horaSel!);

    // Persistir en SQLite y notificar
    _persistirCitaYNotificar(nueva);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.teal),
            SizedBox(width: 8),
            Text('¡Cita confirmada!'),
          ],
        ),
        content: Text(
          'Número: ${nueva.id}\n${nueva.especialidad} - ${nueva.profesional}\n${nueva.sede}\n$diaSel • $horaSel',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cita ${nueva.id} creada y cupo bloqueado'),
                ),
              );
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _persistirCitaYNotificar(Cita nueva) async {
    try {
      await DbHelper.instance.insertCita(nueva);
      final perfil = await DbHelper.instance.getPerfil();
      if (perfil.notificacionesActivas) {
        await NotificationService.instance.mostrarNotificacionCita(
          titulo: '¡Cita confirmada en MediCitas!',
          especialidad: nueva.especialidad,
          profesional: nueva.profesional,
          sede: nueva.sede,
          fecha: diaSel,
          hora: horaSel!,
        );
      }
    } catch (_) {
      // Si la base de datos se cerró por reinicio de test o finalización, silenciar
    }
  }

  String _to24(String h) {
    // "10:30 a. m." -> "10:30:00"
    final clean = h.replaceAll('a. m.', '').replaceAll('p. m.', '').trim();
    final isPM = h.contains('p.');
    var parts = clean.split(':');
    int hour = int.parse(parts[0]);
    final min = parts[1];
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:$min:00';
  }
}

class _Stepper extends StatelessWidget {
  final int paso;
  const _Stepper({required this.paso});
  @override
  Widget build(BuildContext context) {
    Widget dot(int n, String label) {
      final active = paso >= n;
      return Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? AppColors.primary : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    Widget line(bool active) => Expanded(
      child: Container(
        height: 2,
        color: active ? AppColors.primary : Colors.grey.shade300,
      ),
    );
    return Row(
      children: [
        dot(1, 'Servicio'),
        line(paso > 1),
        dot(2, 'Fecha y hora'),
        line(paso > 2),
        dot(3, 'Confirmar'),
      ],
    );
  }
}
