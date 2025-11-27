import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "MindfulPosture",
          style: TextStyle(
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------
            // ENCABEZADO BONITO
            // ---------------------------
            Text(
              "Bienvenido 👋",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? "",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 16,
                color: AppColors.softGrey,
              ),
            ),

            const SizedBox(height: 25),

            // ---------------------------
            // TARJETA DE CONSEJO
            // ---------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.darkText,
                  ),
                  const SizedBox(width: 10),

                  // 🔥 Esto evita overflow
                  const Expanded(
                    child: Text(
                      "Consejo: Haz una pausa breve cada 50 minutos para estirar tu cuello y relajar la espalda.",
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 15,
                        height: 1.4,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------------------------
            // ESTADÍSTICAS RÁPIDAS
            // ---------------------------
            Text(
              "Tu Actividad",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                _buildStatCard(
                  title: "Rutinas",
                  value: "✔",
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: "Sensores",
                  value: "✔",
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: "Logs",
                  value: "✔",
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ---------------------------
            // ÚLTIMOS REGISTROS
            // ---------------------------
            Text(
              "Últimos movimientos",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 14),

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("logs")
                  .where("userId", isEqualTo: user?.uid)
                  .orderBy("timestamp", descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text(
                    "No hay registros todavía.",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      color: AppColors.softGrey,
                    ),
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final time = (doc["timestamp"] as Timestamp).toDate();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${doc["message"]} • ${time.hour}:${time.minute.toString().padLeft(2, "0")}",
                              style: const TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(.17),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontFamily: "Nunito",
                fontSize: 14,
                color: AppColors.softGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
