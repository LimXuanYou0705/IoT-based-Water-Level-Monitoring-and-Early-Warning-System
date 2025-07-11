import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../helper/icon_picker_helper.dart';

class AddIncidentTypeScreen extends StatefulWidget {
  const AddIncidentTypeScreen({super.key});

  @override
  State<AddIncidentTypeScreen> createState() => _AddIncidentTypeScreenState();
}

class _AddIncidentTypeScreenState extends State<AddIncidentTypeScreen> {
  Future<bool> _isNameExists(String name, {String? excludeId}) async {
    final query =
        await FirebaseFirestore.instance.collection('incident_type').get();

    final finalName = name.trim().toLowerCase();

    if (excludeId != null) {
      return query.docs.any(
        (doc) =>
            doc.id != excludeId &&
            (doc.data())['name'].toString().toLowerCase() == finalName,
      );
    }

    return query.docs.any(
      (doc) => (doc.data())['name'].toString().toLowerCase() == finalName,
    );
  }

  Future<void> _showAddTypeModal() async {
    final nameController = TextEditingController();
    String? selectedLogo;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(
            context,
          ).viewInsets.add(const EdgeInsets.all(16)),
          child: StatefulBuilder(
            builder:
                (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add Incident Type",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Type Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: selectedLogo,
                      hint: const Text("Pick Icon"),
                      isExpanded: true,
                      menuMaxHeight: 250,
                      items:
                          incidentIcons.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Row(
                                children: [
                                  Icon(entry.value),
                                  const SizedBox(width: 8),
                                  Text(entry.key),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedLogo = value),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                      onPressed: () async {
                        Navigator.pop(context);

                        if (nameController.text.trim().isEmpty ||
                            selectedLogo == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        final nameExists = await _isNameExists(
                          nameController.text.trim(),
                        );
                        if (nameExists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Name already exists (case insensitive)',
                              ),
                            ),
                          );
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection('incident_type')
                            .add({
                              'name': nameController.text.trim(),
                              'logo': selectedLogo,
                            });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incident type added successfully'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }

  Future<void> _showEditTypeModal(
    String id,
    String currentName,
    String currentLogo,
  ) async {
    final nameController = TextEditingController(text: currentName);
    String? selectedLogo = currentLogo;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(
            context,
          ).viewInsets.add(const EdgeInsets.all(16)),
          child: StatefulBuilder(
            builder:
                (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Edit Incident Type",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Type Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: selectedLogo,
                      hint: const Text("Pick Icon"),
                      isExpanded: true,
                      menuMaxHeight: 250,
                      items:
                          incidentIcons.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Row(
                                children: [
                                  Icon(entry.value),
                                  const SizedBox(width: 8),
                                  Text(entry.key),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedLogo = value),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Update"),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            selectedLogo == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        final nameExists = await _isNameExists(
                          nameController.text.trim(),
                          excludeId: id,
                        );
                        if (nameExists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Name already exists (case insensitive)',
                              ),
                            ),
                          );
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection('incident_type')
                            .doc(id)
                            .update({
                              'name': nameController.text.trim(),
                              'logo': selectedLogo,
                            });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incident type updated successfully'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }

  Future<void> _deleteIncidentType(String id) async {
    await FirebaseFirestore.instance
        .collection('incident_type')
        .doc(id)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incident type deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incident Types")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('incident_type')
                .orderBy('name')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final types = snapshot.data!.docs;
          if (types.isEmpty) {
            return const Center(child: Text("No types added."));
          }

          return ListView.builder(
            itemCount: types.length,
            itemBuilder: (context, index) {
              final doc = types[index];
              final data = doc.data() as Map<String, dynamic>;
              final iconName = data['logo'];

              return ListTile(
                leading: Icon(incidentIcons[iconName] ?? Icons.warning),
                title: Text(data['name']),
                subtitle: Text("Icon: $iconName"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => _showEditTypeModal(
                            doc.id,
                            data['name'],
                            data['logo'],
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteIncidentType(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTypeModal,
        icon: const Icon(Icons.add),
        label: const Text("Add Type"),
      ),
    );
  }
}
