import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../database/db_helper.dart';
import '../models/models.dart';
import '../widgets/section_header.dart';
import '../widgets/info_banner.dart';
import 'agendar_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;
  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Cita? _proxima =
      MockData.citas.where((c) => c.estado == 'Confirmada').firstOrNull;
  String _nombre = 'José';
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final prox = await DbHelper.instance.getProximaCita();
      final perfil = await DbHelper.instance.getPerfil();
      if (mounted) {
        setState(() {
          _proxima = prox;
          _nombre = perfil.nombre.trim().split(' ').first;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('Error al leer de SQLite en HomeScreen: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 190,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFF14919B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 36, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          ExcludeSemantics(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MediCitas',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Ver recordatorios',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              final msg = _proxima != null
                                  ? 'Próxima cita en SQLite: ${_proxima!.especialidad} (${_proxima!.sede})'
                                  : 'RF-10: Sin recordatorios pendientes';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg)),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hola, $_nombre',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          '¿Cómo podemos ayudarte?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final margen = constraints.crossAxisExtent > 752
                    ? (constraints.crossAxisExtent - 720) / 2
                    : 16.0;
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: margen, vertical: 16),
                  sliver: SliverList.list(
                    children: [
                      const SectionHeader(title: 'Tu próxima cita'),
                      const SizedBox(height: 10),
                      if (_cargando)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_proxima != null)
                        _ProximaCitaCard(
                          cita: _proxima!,
                          onVerDetalle: () => widget.onTabChange(1),
                        )
                      else
                        const _SinCitasCard(),
                      const SizedBox(height: 18),
                      const SectionHeader(title: 'Acciones rápidas'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.add,
                              iconBg: AppColors.primary,
                              title: 'Agendar cita',
                              subtitle: 'Consulta horarios',
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AgendarScreen(),
                                  ),
                                );
                                _cargarDatos();
                              },
                              bg: const Color(0xFFEAF2F8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.list_alt,
                              iconBg: AppColors.accent,
                              title: 'Mis citas',
                              subtitle: 'Consulta o cancela',
                              onTap: () => widget.onTabChange(1),
                              bg: const Color(0xFFFFF3E0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const SectionHeader(title: 'Especialidades'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: MockData.especialidades
                            .take(3)
                            .map(
                              (e) => Chip(
                                label: Text(
                                  e.nombre,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: MockData.especialidades.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final e = MockData.especialidades[i];
                            return Container(
                              width: 102,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ExcludeSemantics(
                                    child: Text(
                                      e.icon,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Flexible(
                                    child: Text(
                                      e.nombre,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const InfoBanner(
                        text:
                            'RF-03 a RF-06: Consulta sede/especialidad → disponibilidad → agendamiento',
                        icon: Icons.verified_user,
                        bgColor: Color(0xFFE6F0F2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProximaCitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback onVerDetalle;
  const _ProximaCitaCard({required this.cita, required this.onVerDetalle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            ExcludeSemantics(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0F2),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MG',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cita.especialidad,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    cita.profesional,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    '${_weekDay(cita.fechaHora)}, ${cita.fechaHora.day} de ${_mes(cita.fechaHora)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F5F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _hora(cita.fechaHora),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onVerDetalle,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          minimumSize: const Size(0, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Ver detalle',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SinCitasCard extends StatelessWidget {
  const _SinCitasCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.event_available_outlined, color: AppColors.textLight),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No tienes citas próximas. Agenda una desde Acciones rápidas.',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color bg;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _weekDay(DateTime d) {
  const dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  return dias[d.weekday - 1];
}

String _mes(DateTime d) {
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
  return meses[d.month - 1];
}

String _hora(DateTime d) {
  final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour >= 12 ? 'p. m.' : 'a. m.';
  return '$h:$m $ap';
}
