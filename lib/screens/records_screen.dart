import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/farm_record.dart';

/// Records list.
///
/// PERMISSIONS (as you specified):
/// - Admin: can edit AND delete any record.
/// - Regular farm user: can edit, but the delete button is hidden/disabled.
///
/// EXPORT: The "Export to Excel" button builds a real .xlsx file on the
/// device using the `excel` package, then opens the native share sheet
/// (via `share_plus`) so the user can save it to Drive, email it, etc.
class RecordsScreen extends StatelessWidget {
  final List<FarmRecord> records;
  final bool isAdmin;
  final void Function(String id) onDelete;
  final void Function(FarmRecord updated) onEdit;

  const RecordsScreen({
    super.key,
    required this.records,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
  });

  Future<void> _exportToExcel(BuildContext context) async {
    final excelFile = Excel.createExcel();
    final sheet = excelFile['Records'];

    sheet.appendRow([
      TextCellValue('Tag Number'),
      TextCellValue('Field 1'),
      TextCellValue('Field 2'),
      TextCellValue('Field 3'),
      TextCellValue('Created By'),
      TextCellValue('Created At'),
    ]);

    for (final record in records) {
      sheet.appendRow([
        TextCellValue(record.tagNumber),
        TextCellValue(record.fieldOne),
        TextCellValue(record.fieldTwo),
        TextCellValue(record.fieldThree),
        TextCellValue(record.createdBy),
        TextCellValue(record.createdAt.toString()),
      ]);
    }

    final bytes = excelFile.encode();
    if (bytes == null) return;

    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/farm_records_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(filePath)], text: 'Farm Records Export');
  }

  void _confirmDelete(BuildContext context, FarmRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: Text('This will permanently delete tag "${record.tagNumber}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onDelete(record.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editRecordDialog(BuildContext context, FarmRecord record) {
    final f1 = TextEditingController(text: record.fieldOne);
    final f2 = TextEditingController(text: record.fieldTwo);
    final f3 = TextEditingController(text: record.fieldThree);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Tag ${record.tagNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: f1, decoration: const InputDecoration(labelText: 'Field 1')),
            TextField(controller: f2, decoration: const InputDecoration(labelText: 'Field 2')),
            TextField(controller: f3, decoration: const InputDecoration(labelText: 'Field 3')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onEdit(FarmRecord(
                id: record.id,
                tagNumber: record.tagNumber,
                fieldOne: f1.text.trim(),
                fieldTwo: f2.text.trim(),
                fieldThree: f3.text.trim(),
                createdBy: record.createdBy,
                createdAt: record.createdAt,
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export to Excel',
            onPressed: records.isEmpty ? null : () => _exportToExcel(context),
          ),
        ],
      ),
      body: records.isEmpty
          ? const Center(child: Text('No records yet. Scan a tag to add one.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      record.tagNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${record.fieldOne} • ${record.fieldTwo} • ${record.fieldThree}\n'
                      'by ${record.createdBy}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () => _editRecordDialog(context, record),
                        ),
                        // Only admins see/can use the delete button.
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, record),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
