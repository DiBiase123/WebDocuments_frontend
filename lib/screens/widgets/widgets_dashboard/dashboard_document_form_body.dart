import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentFormBody extends StatelessWidget {
  final TextEditingController descCtl, dateCtl;
  final List<dynamic> enti;
  final List<String> enteIds;
  final PlatformFile? file;
  final bool isEditing;
  final ThemeData theme;
  final VoidCallback onPickFile;
  final VoidCallback onPickDate;
  final ValueChanged<String> onDateChanged;
  final VoidCallback onAddEnte;
  final Function(String id, bool selected) onEnteToggle;

  const DocumentFormBody({
    super.key,
    required this.descCtl,
    required this.dateCtl,
    required this.enti,
    required this.enteIds,
    required this.file,
    required this.isEditing,
    required this.theme,
    required this.onPickFile,
    required this.onPickDate,
    required this.onDateChanged,
    required this.onAddEnte,
    required this.onEnteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isEditing) ...[
          ElevatedButton.icon(
            onPressed: onPickFile,
            icon: const Icon(Icons.upload_file, size: 28),
            label: Text(
              file != null ? file!.name : 'Seleziona file PDF',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        TextFormField(
          controller: descCtl,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            labelText: 'Descrizione',
            labelStyle: const TextStyle(fontSize: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => v?.trim().isEmpty != false ? 'Obbligatorio' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: dateCtl,
          onChanged: onDateChanged,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            labelText: 'Data (GG/MM/AAAA)',
            hintText: '08/07/2026',
            labelStyle: const TextStyle(fontSize: 18),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 60,
              minHeight: 44,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.calendar_month, size: 36),
                onPressed: onPickDate,
                padding: EdgeInsets.zero,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) => v?.trim().isEmpty != false ? 'Obbligatorio' : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enti',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: enti.map((e) {
                      final id = e['id'] as String, sel = enteIds.contains(id);
                      return FilterChip(
                        label: Text(
                          e['nome'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            color: sel ? Colors.white : null,
                          ),
                        ),
                        selected: sel,
                        onSelected: (v) => onEnteToggle(id, v),
                        selectedColor: theme.colorScheme.primary.withAlpha(100),
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFFF08A5D),
                size: 36,
              ),
              onPressed: onAddEnte,
              tooltip: 'Nuovo ente',
            ),
          ],
        ),
      ],
    );
  }
}
