import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

import '../services/log_service.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  // Lecturas del acelerómetro
  double accelX = 0;
  double accelY = 0;
  double accelZ = 0;

  // Proximidad
  bool isNear = false;

  // Estados/flags para evitar logs repetidos
  bool badPosture = false;
  bool tooClose = false;

  // Flags internos para controlar si ya se registró el evento
  bool _accelLogged = false;
  bool _proximityLogged = false;

  // Timestamps para throttling (no más de 1 log cada X segundos)
  DateTime? _lastAccelLogTime;
  DateTime? _lastProximityLogTime;
  final Duration _minLogInterval = const Duration(seconds: 5);

  // Subscripciones a streams
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<int>? _proximitySub;

  // Servicio para guardar logs
  final LogService _logService = LogService();

  @override
  void initState() {
    super.initState();

    // Suscribirse al acelerómetro
    _accelSub = accelerometerEvents.listen((AccelerometerEvent event) {
      // Actualizar lecturas
      final newX = event.x;
      final newY = event.y;
      final newZ = event.z;

      // Definir regla simple para detectar mala postura:
      // Si la componente X (inclinación lateral / hacia adelante según el dispositivo) excede un umbral.
      // Ajusta el umbral según pruebas en tu dispositivo real.
      const double postureThreshold = 5.0;
      final bool newBadPosture = newX.abs() > postureThreshold;

      // Actualizar estado y registrar si corresponde (con throttling)
      setState(() {
        accelX = newX;
        accelY = newY;
        accelZ = newZ;
        badPosture = newBadPosture;
      });

      final now = DateTime.now();

      // Registrar evento de mala postura
      if (newBadPosture && !_accelLogged) {
        if (_lastAccelLogTime == null ||
            now.difference(_lastAccelLogTime!) >= _minLogInterval) {
          _logService
              .addLog("bad_posture", "Postura incorrecta detectada")
              .catchError((e) {
                // opcional: manejar error de logging sin romper la app
              });
          _accelLogged = true;
          _lastAccelLogTime = now;
        }
      }

      // Registrar evento de corrección de postura
      if (!newBadPosture && _accelLogged) {
        if (_lastAccelLogTime == null ||
            now.difference(_lastAccelLogTime!) >= _minLogInterval) {
          _logService
              .addLog("good_posture", "Postura corregida")
              .catchError((e) {});
          _accelLogged = false;
          _lastAccelLogTime = now;
        }
      }
    });

    // Suscribirse al sensor de proximidad
    _proximitySub = ProximitySensor.events.listen((int event) {
      final bool newNear = event > 0;

      setState(() {
        isNear = newNear;
        tooClose = newNear;
      });

      final now = DateTime.now();

      if (newNear && !_proximityLogged) {
        if (_lastProximityLogTime == null ||
            now.difference(_lastProximityLogTime!) >= _minLogInterval) {
          _logService
              .addLog("too_close", "El usuario está demasiado cerca")
              .catchError((e) {});
          _proximityLogged = true;
          _lastProximityLogTime = now;
        }
      }

      if (!newNear && _proximityLogged) {
        if (_lastProximityLogTime == null ||
            now.difference(_lastProximityLogTime!) >= _minLogInterval) {
          _logService
              .addLog(
                "correct_distance",
                "El usuario volvió a distancia segura",
              )
              .catchError((e) {});
          _proximityLogged = false;
          _lastProximityLogTime = now;
        }
      }
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _proximitySub?.cancel();
    super.dispose();
  }

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      color: color.withOpacity(0.12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitoreo de Sensores")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Postura
              _statusCard(
                icon: badPosture
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: badPosture ? Colors.red : Colors.green,
                title: badPosture
                    ? "Postura incorrecta detectada"
                    : "Postura correcta",
                subtitle: badPosture
                    ? "Tu cabeza está inclinada. Enderézala un poco."
                    : "Buen trabajo. Mantén esta postura.",
              ),

              const SizedBox(height: 16),

              // Proximidad
              _statusCard(
                icon: tooClose ? Icons.visibility_off : Icons.visibility,
                color: tooClose ? Colors.red : Colors.blue,
                title: tooClose
                    ? "Muy cerca de la pantalla"
                    : "Distancia adecuada",
                subtitle: tooClose
                    ? "Aléjate un poco para cuidar tu vista."
                    : "Tu distancia es saludable.",
              ),

              const SizedBox(height: 24),

              // Datos en tiempo real
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Datos en tiempo real",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        "X",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(accelX.toStringAsFixed(2)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Y",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(accelY.toStringAsFixed(2)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Z",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(accelZ.toStringAsFixed(2)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Proximidad: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(isNear ? "Objeto cercano" : "Nada cerca"),
                ],
              ),

              const SizedBox(height: 20),

              // Botón de prueba para crear un log manual (útil para debugging / pruebas)
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _logService.addLog("debug", "Log manual desde UI");
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Log creado")));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error al crear log: $e")),
                    );
                  }
                },
                icon: const Icon(Icons.bug_report),
                label: const Text("Crear log de prueba"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
