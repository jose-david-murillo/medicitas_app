import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/responsive_content.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController(text: 'José David Murillo');
  final _correoCtrl = TextEditingController(text: 'jose.murillo@unad.edu.co');
  final _telCtrl = TextEditingController(text: '300 123 4567');
  String canal = 'Correo';
  bool notif = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  String? _validarNombre(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'El nombre es obligatorio';
    if (v.length < 3) return 'Ingresa al menos 3 caracteres';
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'.-]+$").hasMatch(v)) {
      return 'El nombre solo admite letras y espacios';
    }
    return null;
  }

  String? _validarCorreo(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v)) {
      return 'Ingresa un correo válido (ejemplo@dominio.com)';
    }
    return null;
  }

  String? _validarTelefono(String? valor) {
    final soloDigitos = (valor ?? '').replaceAll(RegExp(r'\D'), '');
    if (soloDigitos.isEmpty) return 'El teléfono es obligatorio';
    if (soloDigitos.length < 7 || soloDigitos.length > 10) {
      return 'El teléfono debe tener entre 7 y 10 dígitos';
    }
    return null;
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos marcados en rojo antes de guardar'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil actualizado. Canal: $canal')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ResponsiveContent(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ExcludeSemantics(
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primary,
                              child: const Text(
                                'JM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'José David Murillo',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'CC 1017234567',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                Text(
                                  'Paciente',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Editar datos del perfil',
                            onPressed: () => FocusScope.of(context).unfocus(),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gestión del perfil (RF-02)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nombreCtrl,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: _validarNombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validarCorreo,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    validator: _validarTelefono,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      helperText: 'Entre 7 y 10 dígitos',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Canal autorizado para notificaciones',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: canal,
                    items: const [
                      DropdownMenuItem(value: 'Correo', child: Text('Correo')),
                      DropdownMenuItem(value: 'SMS', child: Text('SMS')),
                      DropdownMenuItem(
                        value: 'WhatsApp',
                        child: Text('WhatsApp'),
                      ),
                    ],
                    onChanged: (v) => setState(() => canal = v!),
                    validator: (v) => v == null
                        ? 'Selecciona un canal de notificación'
                        : null,
                  ),
                  SwitchListTile(
                    value: notif,
                    onChanged: (v) => setState(() => notif = v),
                    title: const Text(
                      'Recibir recordatorios (RF-10)',
                      style: TextStyle(fontSize: 13),
                    ),
                    subtitle: const Text(
                      'Notificación previa con fecha, hora y sede',
                      style: TextStyle(fontSize: 11),
                    ),
                    activeThumbColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _guardar,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar cambios'),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings_outlined,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Administración de oferta (RF-12)',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Usuario autorizado puede crear/actualizar/inactivar sedes, especialidades, profesionales y reglas de disponibilidad.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'RF-12: Módulo admin simulado',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Gestionar oferta'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppColors.textLight,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'RF-11 Consulta de agenda (Profesional)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    ),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'v1.0.0 • Flutter 3.35.5 • UNAD 2026',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
