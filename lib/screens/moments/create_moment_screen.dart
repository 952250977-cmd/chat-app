import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/app_data.dart';

class CreateMomentScreen extends StatefulWidget {
  const CreateMomentScreen({super.key});

  @override
  State<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends State<CreateMomentScreen> {
  final _contentController = TextEditingController();
  final List<String> _imagePaths = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage();
    setState(() => _imagePaths.addAll(files.map((f) => f.path)));
  }

  void _publish() {
    if (_contentController.text.trim().isEmpty && _imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入内容或选择图片')));
      return;
    }
    context.read<AppData>().createMoment(_contentController.text.trim(), _imagePaths);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发布成功')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布动态'),
        actions: [
          TextButton(onPressed: _publish, child: const Text('发布', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: '分享你的想法...', border: InputBorder.none),
              maxLines: 6,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),
            if (_imagePaths.isNotEmpty)
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _imagePaths.map((path) {
                  return Stack(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover)),
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePaths.remove(path)),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: _pickImages, icon: const Icon(Icons.add_photo_alternate), label: const Text('添加图片')),
          ],
        ),
      ),
    );
  }
}
