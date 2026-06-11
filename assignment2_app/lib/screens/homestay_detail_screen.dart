// lib/screens/homestay_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/homestay.dart';

class HomestayDetailScreen extends StatelessWidget {
  final Homestay homestay;

  const HomestayDetailScreen({super.key, required this.homestay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          // ── Collapsible image header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                homestay.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background:
                  homestay.imageUrl != null && homestay.imageUrl!.isNotEmpty
                  ? Image.network(
                      homestay.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _headerPlaceholder(),
                    )
                  : _headerPlaceholder(),
            ),
          ),

          // ── Detail body ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name card
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homestay.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.location_on,
                          '${homestay.district}, ${homestay.state}',
                        ),
                        if (homestay.price != null)
                          _infoRow(
                            Icons.payments_outlined,
                            'RM ${homestay.price!.toStringAsFixed(2)} / night',
                            valueColor: Colors.teal,
                          ),
                      ],
                    ),
                  ),

                  // Contact card
                  if (homestay.phone != null || homestay.email != null)
                    _sectionCard(
                      title: 'Contact',
                      child: Column(
                        children: [
                          if (homestay.phone != null)
                            _infoRow(Icons.phone, homestay.phone!),
                          if (homestay.email != null)
                            _infoRow(Icons.email, homestay.email!),
                        ],
                      ),
                    ),

                  // Description card
                  if (homestay.description != null &&
                      homestay.description!.isNotEmpty)
                    _sectionCard(
                      title: 'About',
                      child: Text(
                        homestay.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  // Location detail card
                  _sectionCard(
                    title: 'Location Details',
                    child: Column(
                      children: [
                        _labeledRow('State', homestay.state),
                        _labeledRow('District', homestay.district),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _headerPlaceholder() {
    return Container(
      color: Colors.teal.shade100,
      child: const Center(
        child: Icon(Icons.home_work, size: 80, color: Colors.teal),
      ),
    );
  }

  Widget _sectionCard({String? title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const Divider(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            ': $value',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
