import '../models/models.dart';

class MockData {
  static List<Sede> sedes = [
    Sede(id: '1', nombre: 'Sede Centro'),
    Sede(id: '2', nombre: 'Sede Norte'),
    Sede(id: '3', nombre: 'Sede Sur'),
  ];

  static List<Especialidad> especialidades = [
    Especialidad(id: 'mg', nombre: 'Medicina general', icon: '🩺'),
    Especialidad(id: 'od', nombre: 'Odontología', icon: '🦷'),
    Especialidad(id: 'pe', nombre: 'Pediatría', icon: '👶'),
    Especialidad(id: 'ps', nombre: 'Psicología', icon: '🧠'),
    Especialidad(id: 'ca', nombre: 'Cardiología', icon: '❤️'),
  ];

  static List<Profesional> profesionales = [
    Profesional(
      id: '1',
      nombre: 'Dra. Laura Gómez',
      especialidadId: 'mg',
      sede: 'Sede Centro',
      avatar: 'LG',
    ),
    Profesional(
      id: '2',
      nombre: 'Dr. Carlos Pérez',
      especialidadId: 'mg',
      sede: 'Sede Norte',
      avatar: 'CP',
    ),
    Profesional(
      id: '3',
      nombre: 'Dra. Ana Torres',
      especialidadId: 'od',
      sede: 'Sede Centro',
      avatar: 'AT',
    ),
    Profesional(
      id: '4',
      nombre: 'Dr. Javier Ruiz',
      especialidadId: 'pe',
      sede: 'Sede Sur',
      avatar: 'JR',
    ),
    Profesional(
      id: '5',
      nombre: 'Dra. Sofia Méndez',
      especialidadId: 'ps',
      sede: 'Sede Centro',
      avatar: 'SM',
    ),
  ];

  static List<Cita> citas = [
    Cita(
      id: 'CIT-2026-001',
      especialidad: 'Medicina general',
      profesional: 'Dra. Laura Gómez',
      sede: 'Sede Centro',
      fechaHora: DateTime(2026, 11, 2, 10, 30),
      estado: 'Confirmada',
    ),
    Cita(
      id: 'CIT-2026-002',
      especialidad: 'Odontología',
      profesional: 'Dra. Ana Torres',
      sede: 'Sede Centro',
      fechaHora: DateTime(2026, 11, 3, 14, 15),
      estado: 'Confirmada',
    ),
    Cita(
      id: 'CIT-2026-003',
      especialidad: 'Pediatría',
      profesional: 'Dr. Javier Ruiz',
      sede: 'Sede Sur',
      fechaHora: DateTime(2026, 9, 10, 9, 0),
      estado: 'Atendida',
    ),
  ];

  static Map<String, List<Slot>> horariosPorDia = {
    '2026-11-02': [
      Slot('8:00 a. m.', true),
      Slot('10:30 a. m.', true),
      Slot('2:15 p. m.', true),
      Slot('4:00 p. m.', false),
    ],
    '2026-11-03': [
      Slot('8:00 a. m.', true),
      Slot('9:30 a. m.', true),
      Slot('11:00 a. m.', false),
      Slot('3:00 p. m.', true),
    ],
    '2026-11-04': [
      Slot('8:30 a. m.', true),
      Slot('10:00 a. m.', true),
      Slot('1:00 p. m.', true),
    ],
    '2026-11-05': [
      Slot('8:00 a. m.', false),
      Slot('10:30 a. m.', true),
      Slot('2:15 p. m.', true),
    ],
    '2026-11-06': [Slot('9:00 a. m.', true), Slot('11:30 a. m.', true)],
  };
}
