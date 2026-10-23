import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../widgets/responsive_content.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});
  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final proximas = MockData.citas
        .where((c) => c.estado == 'Confirmada')
        .toList();
    final historial = MockData.citas
        .where((c) => c.estado != 'Confirmada')
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _lista(proximas, esProximas: true),
          _lista(historial, esProximas: false),
        ],
      ),
    );
  }

  Widget _lista(List<Cita> citas, {required bool esProximas}) {
    if (citas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 40,
                color: AppColors.textLight,
              ),
              SizedBox(height: 8),
              Text(
                'No hay citas en esta sección',
                style: TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
        ),
      );
    }
    return ResponsiveContent(
      maxWidth: 720,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: citas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final c = citas[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.estado == 'Confirmada'
                              ? const Color(0xFFE6F5F0)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.estado,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c.estado == 'Confirmada'
                                ? AppColors.teal
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        c.id,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.especialidad,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${c.profesional} • ${c.sede}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${c.fechaHora.day}/${c.fechaHora.month}/2026  ${_fmtHora(c.fechaHora)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  if (esProximas) ...[
                    const SizedBox(height: 10),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _reprogramar(c),
                            icon: const Icon(Icons.edit_calendar, size: 16),
                            label: const Text(
                              'Reprogramar',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelar(c),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmtHora(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'p. m.' : 'a. m.';
    return '$h:$m $ap';
  }

  void _cancelar(Cita c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: Text(
          '¿Confirmas cancelar ${c.id}? Se liberará el horario (RF-09).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => c.estado = 'Cancelada');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${c.id} cancelada y horario liberado')),
              );
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _reprogramar(Cita c) {
    // RF-08: seleccionar nuevo horario
    String nuevoDia = '2026-11-04';
    String nuevaHora = '9:30 a. m.';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reprogramar cita (RF-08)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona nuevo horario disponible:'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: nuevoDia,
              decoration: const InputDecoration(labelText: 'Nueva fecha'),
              items: const [
                DropdownMenuItem(
                  value: '2026-11-04',
                  child: Text('4 nov 2026'),
                ),
                DropdownMenuItem(
                  value: '2026-11-05',
                  child: Text('5 nov 2026'),
                ),
              ],
              onChanged: (v) {
                if (v != null) nuevoDia = v;
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: nuevaHora,
              decoration: const InputDecoration(labelText: 'Nueva hora'),
              items: const [
                DropdownMenuItem(
                  value: '9:30 a. m.',
                  child: Text('9:30 a. m.'),
                ),
                DropdownMenuItem(
                  value: '11:00 a. m.',
                  child: Text('11:00 a. m.'),
                ),
              ],
              onChanged: (v) {
                if (v != null) nuevaHora = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => c.fechaHora = DateTime.parse(
                  '$nuevoDia ${_to24(nuevaHora)}',
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita reprogramada correctamente'),
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  String _to24(String h) {
    final esPM = h.contains('p. m.');
    final limpio = h.replaceAll('a. m.', '').replaceAll('p. m.', '').trim();
    final partes = limpio.split(':');
    var hora = int.parse(partes[0]);
    final minuto = partes.length > 1 ? partes[1].padLeft(2, '0') : '00';
    if (esPM && hora != 12) hora += 12;
    if (!esPM && hora == 12) hora = 0;
    return '${hora.toString().padLeft(2, '0')}:$minuto:00';
  }
}
