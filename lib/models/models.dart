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
  String estado; // Confirmada, Cancelada, Reprogramada, Atendida

  Cita({
    required this.id,
    required this.especialidad,
    required this.profesional,
    required this.sede,
    required this.fechaHora,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'especialidad': especialidad,
      'profesional': profesional,
      'sede': sede,
      'fechaHora': fechaHora.toIso8601String(),
      'estado': estado,
    };
  }

  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map['id'] as String,
      especialidad: map['especialidad'] as String,
      profesional: map['profesional'] as String,
      sede: map['sede'] as String,
      fechaHora: DateTime.parse(map['fechaHora'] as String),
      estado: map['estado'] as String,
    );
  }
}

class Slot {
  final String hora; // "10:30 a. m."
  final bool disponible;
  Slot(this.hora, this.disponible);
}

class PerfilPaciente {
  final int id;
  final String nombre;
  final String documento;
  final String correo;
  final String telefono;
  final String canal;
  final bool notificacionesActivas;
  final String? fotoRuta;

  PerfilPaciente({
    this.id = 1,
    required this.nombre,
    required this.documento,
    required this.correo,
    required this.telefono,
    required this.canal,
    required this.notificacionesActivas,
    this.fotoRuta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'documento': documento,
      'correo': correo,
      'telefono': telefono,
      'canal': canal,
      'notificacionesActivas': notificacionesActivas ? 1 : 0,
      'fotoRuta': fotoRuta,
    };
  }

  factory PerfilPaciente.fromMap(Map<String, dynamic> map) {
    return PerfilPaciente(
      id: map['id'] as int? ?? 1,
      nombre: map['nombre'] as String? ?? 'José David Murillo',
      documento: map['documento'] as String? ?? 'CC 1017234567',
      correo: map['correo'] as String? ?? 'jose.murillo@unad.edu.co',
      telefono: map['telefono'] as String? ?? '300 123 4567',
      canal: map['canal'] as String? ?? 'Correo',
      notificacionesActivas: (map['notificacionesActivas'] as int? ?? 1) == 1,
      fotoRuta: map['fotoRuta'] as String?,
    );
  }

  PerfilPaciente copyWith({
    int? id,
    String? nombre,
    String? documento,
    String? correo,
    String? telefono,
    String? canal,
    bool? notificacionesActivas,
    String? fotoRuta,
    bool clearFoto = false,
  }) {
    return PerfilPaciente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      documento: documento ?? this.documento,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      canal: canal ?? this.canal,
      notificacionesActivas: notificacionesActivas ?? this.notificacionesActivas,
      fotoRuta: clearFoto ? null : (fotoRuta ?? this.fotoRuta),
    );
  }
}
