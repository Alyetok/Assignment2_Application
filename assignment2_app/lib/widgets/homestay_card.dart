// lib/widgets/homestay_card.dart

import 'package:flutter/material.dart';
import '../models/homestay.dart';

class HomestayCard extends StatelessWidget {
  final Homestay homestay;

  const HomestayCard({super.key, required this.homestay});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ────────────────────────────────────────────────────────
          if (homestay.imageUrl != null && homestay.imageUrl!.isNotEmpty)
            Image.network(
              homestay.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderBanner(),
            )
          else
            _placeholderBanner(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name ───────────────────────────────────────────────────
                Text(
                  homestay.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // ── Location ───────────────────────────────────────────────
                _infoRow(
                  Icons.location_on,
                  '${homestay.district}, ${homestay.state}',
                ),

                // ── Price ──────────────────────────────────────────────────
                if (homestay.price != null)
                  _infoRow(
                    Icons.payments_outlined,
                    'RM ${homestay.price!.toStringAsFixed(2)} / night',
                    valueColor: Colors.teal,
                    bold: true,
                  ),

                // ── Phone ──────────────────────────────────────────────────
                if (homestay.phone != null && homestay.phone!.isNotEmpty)
                  _infoRow(Icons.phone, homestay.phone!),

                // ── Description ────────────────────────────────────────────
                if (homestay.description != null &&
                    homestay.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    homestay.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],

                // ── Amenities ──────────────────────────────────────────────
                if (homestay.amenities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: homestay.amenities
                        .map(
                          (a) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Text(
                              a,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderBanner() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.teal.shade50,
      child: const Center(
        child: Icon(Icons.home_work_outlined, size: 48, color: Colors.teal),
      ),
    );
  }
}
