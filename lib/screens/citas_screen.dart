import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../database/db_helper.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../widgets/responsive_content.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});
  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Cita> _proximas =
      MockData.citas.where((c) => c.estado == 'Confirmada').toList();
  List<Cita> _historial =
      MockData.citas.where((c) => c.estado != 'Confirmada').toList();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _cargarCitasDesdeDb();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _cargarCitasDesdeDb() async {
    try {
      final proximas = await DbHelper.instance.getCitasProximas();
      final historial = await DbHelper.instance.getCitasHistorial();
      if (mounted) {
        setState(() {
          _proximas = proximas;
          _historial = historial;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('Error al leer citas desde SQLite: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar citas',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _cargando = true);
              _cargarCitasDesdeDb();
            },
          ),
        ],
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
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _lista(_proximas, esProximas: true),
                _lista(_historial, esProximas: false),
              ],
            ),
    );
  }

  Widget _lista(List<Cita> citas, {required bool esProximas}) {
    if (citas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_busy_outlined,
                size: 40,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 8),
              const Text(
                'No hay citas en esta sección',
                style: TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _cargando = true);
                  _cargarCitasDesdeDb();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Recargar'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargarCitasDesdeDb,
      child: ResponsiveContent(
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
                          '${c.fechaHora.day}/${c.fechaHora.month}/${c.fechaHora.year}  ${_fmtHora(c.fechaHora)}',
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
      ),
    );
  }

  String _fmtHora(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'p. m.' : 'a. m.';
    return '$h:$m $ap';
  }

  String _formatearDiaIso(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _cancelar(Cita c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: Text(
          '¿Confirmas cancelar ${c.id}? Se liberará el horario en la agenda y se actualizará en SQLite (RF-09).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Liberar el horario de la cita cancelada
                final diaAnt = _formatearDiaIso(c.fechaHora);
                final horaAnt = _fmtHora(c.fechaHora);
                MockData.liberarCupo(diaAnt, horaAnt);

                // Actualizar estado en SQLite (Delete lógico)
                await DbHelper.instance.updateEstadoCita(c.id, 'Cancelada');

                await _cargarCitasDesdeDb();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${c.id} cancelada en SQLite y horario liberado',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade700,
                      content: Text('Error al cancelar la cita: $e'),
                    ),
                  );
                }
              }
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _reprogramar(Cita c) {
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                // 1. Liberar cupo anterior
                final diaAnt = _formatearDiaIso(c.fechaHora);
                final horaAnt = _fmtHora(c.fechaHora);
                MockData.liberarCupo(diaAnt, horaAnt);

                // 2. Modificar fechaHora y bloquear nuevo cupo
                c.fechaHora = DateTime.parse('$nuevoDia ${_to24(nuevaHora)}');
                c.estado = 'Confirmada';
                MockData.bloquearCupo(nuevoDia, nuevaHora);

                // 3. Persistir actualización en SQLite (Update)
                await DbHelper.instance.updateCita(c);

                // 4. Notificación local si las notificaciones están activadas
                try {
                  final perfil = await DbHelper.instance.getPerfil();
                  if (perfil.notificacionesActivas) {
                    await NotificationService.instance.mostrarNotificacionCita(
                      titulo: '¡Cita reprogramada con éxito!',
                      especialidad: c.especialidad,
                      profesional: c.profesional,
                      sede: c.sede,
                      fecha: nuevoDia,
                      hora: nuevaHora,
                    );
                  }
                } catch (notifErr) {
                  debugPrint('Aviso al notificar reprogramación: $notifErr');
                }

                await _cargarCitasDesdeDb();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cita reprogramada correctamente en SQLite',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red.shade700,
                      content: Text('Error al reprogramar la cita: $e'),
                    ),
                  );
                }
              }
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
