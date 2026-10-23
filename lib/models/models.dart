class Sede {
  final String id;
  final String nombre;
  Sede({required this.id, required this.nombre});
}

class Especialidad {
  final String id;
  final String nombre;
  final String icon;
  Especialidad({required this.id, required this.nombre, required this.icon});
}

class Profesional {
  final String id;
  final String nombre;
  final String especialidadId;
  final String sede;
  final String avatar;
  Profesional({
    required this.id,
    required this.nombre,
    required this.especialidadId,
    required this.sede,
    required this.avatar,
  });
}

class Cita {
  String id;
  String especialidad;
  String profesional;
  String sede;
  DateTime fechaHora;
  String estado; // Confirmada, Cancelada, Reprogramada
  Cita({
    required this.id,
    required this.especialidad,
    required this.profesional,
    required this.sede,
    required this.fechaHora,
    required this.estado,
  });
}

class Slot {
  final String hora; // "10:30 a. m."
  final bool disponible;
  Slot(this.hora, this.disponible);
}
