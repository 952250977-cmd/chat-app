import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/app_data.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final contacts = appData.contacts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('添加联系方式'),
          ),
        ),
        Expanded(
          child: contacts.isEmpty
              ? const Center(child: Text('暂无联系方式\n点击上方按钮添加', textAlign: TextAlign.center))
              : ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTypeColor(contact.type),
                          child: Icon(_getTypeIcon(contact.type), color: Colors.white),
                        ),
                        title: Text(contact.type),
                        subtitle: Text(contact.value),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (contact.imagePath != null)
                              IconButton(icon: const Icon(Icons.image), onPressed: () => _showImage(context, contact.imagePath!)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => appData.deleteContact(contact.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case '微信': return Colors.green;
      case 'QQ': return Colors.blue;
      case '电话': return Colors.orange;
      case '邮箱': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '微信': return Icons.chat;
      case 'QQ': return Icons.alternate_email;
      case '电话': return Icons.phone;
      case '邮箱': return Icons.email;
      default: return Icons.contact_mail;
    }
  }

  void _showAddDialog(BuildContext context) {
    final appData = context.read<AppData>();
    String selectedType = '微信';
    final valueController = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加联系方式'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: '类型'),
                  items: ['微信', 'QQ', '电话', '邮箱', '其他']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(controller: valueController, decoration: const InputDecoration(labelText: '联系方式', hintText: '输入账号/号码')),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (file != null) setDialogState(() => imagePath = file.path);
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('上传截图/二维码'),
                ),
                if (imagePath != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('已选择图片', style: const TextStyle(fontSize: 12, color: Colors.green))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                if (valueController.text.trim().isEmpty) return;
                appData.addContact(selectedType, valueController.text.trim(), imagePath);
                Navigator.pop(dialogContext);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImage(BuildContext context, String path) {
    showDialog(context: context, builder: (_) => Dialog(child: InteractiveViewer(child: Image.file(path))));
  }
}
