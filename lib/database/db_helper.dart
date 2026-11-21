import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

import 'package:sqflite/utils/utils.dart' as sqflite_utils;

/// Clase auxiliar Singleton para la gestión de persistencia local SQLite.
/// Gestiona las tablas `citas` y `perfil_paciente`.
class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  factory DbHelper() => instance;
  DbHelper._internal();

  static Database? _database;
  static bool _ffiInitialized = false;

  /// Inicializa sqflite FFI si se ejecuta en entornos de prueba (flutter test) o plataformas de escritorio.
  static void initFfiIfNeeded() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      // Desactiva el temporizador de advertencia de bloqueo (10s) de sqflite_common en pruebas
      // ignore: deprecated_member_use
      sqflite_utils.lockWarningDuration = null;
    }
    if (_ffiInitialized || kIsWeb) return;
    if (Platform.environment.containsKey('FLUTTER_TEST') ||
        Platform.isLinux ||
        Platform.isWindows ||
        Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _ffiInitialized = true;
    }
  }

  /// Retorna la instancia de base de datos activa o la inicializa.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Permite inyectar una base de datos específica (e.g. para pruebas unitarias en memoria)
  @visibleForTesting
  void setDatabase(Database? db) {
    _database = db;
  }

  Future<Database> _initDatabase({String dbName = 'medicitas.db'}) async {
    initFfiIfNeeded();
    final dbDir = await getDatabasesPath();
    final fullPath = p.join(dbDir, dbName);

    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE citas (
        id TEXT PRIMARY KEY,
        especialidad TEXT NOT NULL,
        profesional TEXT NOT NULL,
        sede TEXT NOT NULL,
        fechaHora TEXT NOT NULL,
        estado TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE perfil_paciente (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        documento TEXT NOT NULL,
        correo TEXT NOT NULL,
        telefono TEXT NOT NULL,
        canal TEXT NOT NULL,
        notificacionesActivas INTEGER NOT NULL,
        fotoRuta TEXT
      )
    ''');

    await _precargarDatos(db);
  }

  Future<void> _onOpen(Database db) async {
    // Si la base de datos existía pero está vacía, precargar datos iniciales
    final totalCitas = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM citas'),
    ) ?? 0;
    if (totalCitas == 0) {
      await _precargarCitas(db);
    }

    final totalPerfil = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM perfil_paciente'),
    ) ?? 0;
    if (totalPerfil == 0) {
      await _precargarPerfil(db);
    }
  }

  Future<void> _precargarCitas(Database db) async {
    final batch = db.batch();
    for (final c in MockData.citas) {
      batch.insert(
        'citas',
        c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _precargarPerfil(Database db) async {
    await db.insert(
      'perfil_paciente',
      MockData.perfilInicial.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _precargarDatos(Database db) async {
    await _precargarCitas(db);
    await _precargarPerfil(db);
  }

  // =========================================================================
  // CRUD CITAS
  // =========================================================================

  /// Inserta una nueva cita en SQLite y sincroniza el caché en memoria
  Future<int> insertCita(Cita cita) async {
    final db = await database;
    final rowId = await db.insert(
      'citas',
      cita.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Sincronizar MockData en memoria
    if (!MockData.citas.any((c) => c.id == cita.id)) {
      MockData.citas.insert(0, cita);
    }
    return rowId;
  }

  /// Lee todas las citas ordenadas cronológicamente
  Future<List<Cita>> getCitas() async {
    final db = await database;
    final maps = await db.query('citas', orderBy: 'fechaHora DESC');
    return maps.map((m) => Cita.fromMap(m)).toList();
  }

  /// Lee citas confirmadas (próximas)
  Future<List<Cita>> getCitasProximas() async {
    final db = await database;
    final maps = await db.query(
      'citas',
      where: 'estado = ?',
      whereArgs: ['Confirmada'],
      orderBy: 'fechaHora ASC',
    );
    return maps.map((m) => Cita.fromMap(m)).toList();
  }

  /// Lee citas no confirmadas (Historial: Atendidas, Canceladas, etc.)
  Future<List<Cita>> getCitasHistorial() async {
    final db = await database;
    final maps = await db.query(
      'citas',
      where: 'estado != ?',
      whereArgs: ['Confirmada'],
      orderBy: 'fechaHora DESC',
    );
    return maps.map((m) => Cita.fromMap(m)).toList();
  }

  /// Retorna la cita confirmada más próxima (para Home)
  Future<Cita?> getProximaCita() async {
    final proximas = await getCitasProximas();
    return proximas.isNotEmpty ? proximas.first : null;
  }

  /// Actualiza una cita completa (fechaHora, estado, etc.)
  Future<int> updateCita(Cita cita) async {
    final db = await database;
    final count = await db.update(
      'citas',
      cita.toMap(),
      where: 'id = ?',
      whereArgs: [cita.id],
    );
    // Sincronizar en memoria
    final idx = MockData.citas.indexWhere((c) => c.id == cita.id);
    if (idx != -1) {
      MockData.citas[idx] = cita;
    }
    return count;
  }

  /// Actualiza únicamente el estado de una cita (e.g. a 'Cancelada')
  Future<int> updateEstadoCita(String id, String nuevoEstado) async {
    final db = await database;
    final count = await db.update(
      'citas',
      {'estado': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
    // Sincronizar en memoria
    final idx = MockData.citas.indexWhere((c) => c.id == id);
    if (idx != -1) {
      MockData.citas[idx].estado = nuevoEstado;
    }
    return count;
  }

  /// Elimina una cita de SQLite
  Future<int> deleteCita(String id) async {
    final db = await database;
    final count = await db.delete(
      'citas',
      where: 'id = ?',
      whereArgs: [id],
    );
    MockData.citas.removeWhere((c) => c.id == id);
    return count;
  }

  // =========================================================================
  // CRUD PERFIL
  // =========================================================================

  /// Obtiene los datos del paciente desde SQLite
  Future<PerfilPaciente> getPerfil() async {
    final db = await database;
    final maps = await db.query(
      'perfil_paciente',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return PerfilPaciente.fromMap(maps.first);
    }
    // Si no existe, precargar perfil por defecto
    await _precargarPerfil(db);
    return MockData.perfilInicial;
  }

  /// Guarda los cambios del perfil en SQLite
  Future<int> updatePerfil(PerfilPaciente perfil) async {
    final db = await database;
    return await db.insert(
      'perfil_paciente',
      perfil.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza únicamente la foto del perfil
  Future<int> updateFotoPerfil(String? fotoRuta) async {
    final actual = await getPerfil();
    final actualizado = actual.copyWith(fotoRuta: fotoRuta, clearFoto: fotoRuta == null);
    return await updatePerfil(actualizado);
  }

  /// Cierra la base de datos
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Reinicia la base de datos en memoria para pruebas
  @visibleForTesting
  Future<void> resetForTesting() async {
    initFfiIfNeeded();
    await close();
    _database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }
}
