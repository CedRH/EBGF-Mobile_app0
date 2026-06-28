import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'records_screen.dart';
import 'login_screen.dart';
import '../models/farm_record.dart';

/// Home screen after login.
///
/// `isAdmin` controls what the user can do later in [RecordsScreen]
/// (only admins see the delete button). This flag should ultimately come
/// from a "role" field on the user's document in Firestore, not from the
/// placeholder email-contains-"admin" trick used in LoginScreen.
class HomeScreen extends StatefulWidget {
  final String userEmail;
  final bool isAdmin;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.isAdmin,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // In-memory store for now so the UI is fully testable without a backend.
  // Swap this for a Firestore stream once your backend is connected —
  // see the setup guide for exactly where this plugs in.
  final List<FarmRecord> _records = [];

  void _addRecord(FarmRecord record) {
    setState(() => _records.insert(0, record));
  }

  void _deleteRecord(String id) {
    setState(() => _records.removeWhere((r) => r.id == id));
  }

  void _editRecord(FarmRecord updated) {
    setState(() {
      final index = _records.indexWhere((r) => r.id == updated.id);
      if (index != -1) _records[index] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signed in as ${widget.userEmail}',
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              widget.isAdmin ? 'Role: Admin' : 'Role: Farm User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _HomeTile(
                    icon: Icons.camera_alt,
                    label: 'Scan Tag / Add Record',
                    color: const Color(0xFF2E7D32),
                    onTap: () async {
                      final newRecord = await Navigator.of(context).push<FarmRecord>(
                        MaterialPageRoute(
                          builder: (_) => ScanScreen(createdBy: widget.userEmail),
                        ),
                      );
                      if (newRecord != null) _addRecord(newRecord);
                    },
                  ),
                  _HomeTile(
                    icon: Icons.list_alt,
                    label: 'View Records',
                    color: const Color(0xFF1565C0),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RecordsScreen(
                            records: _records,
                            isAdmin: widget.isAdmin,
                            onDelete: _deleteRecord,
                            onEdit: _editRecord,
                          ),
                        ),
                      );
                    },
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

class _HomeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HomeTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
