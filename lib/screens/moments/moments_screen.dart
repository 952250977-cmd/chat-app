import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/app_data.dart';
import 'create_moment_screen.dart';

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final moments = appData.moments;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(appData.currentUser?.displayName[0].toUpperCase() ?? '?'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateMomentScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('分享新鲜事...', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: moments.isEmpty
              ? const Center(child: Text('朋友圈空空如也'))
              : ListView.builder(
                  itemCount: moments.length,
                  itemBuilder: (context, index) {
                    return _MomentCard(moment: moments[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _MomentCard extends StatelessWidget {
  final Moment moment;
  const _MomentCard({required this.moment});

  @override
  Widget build(BuildContext context) {
    final appData = context.read<AppData>();
    final currentUid = appData.currentUser!.uid;
    final isLiked = moment.likes.contains(currentUid);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 20, child: Text(moment.userName[0].toUpperCase())),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(moment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('MM-dd HH:mm').format(moment.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (moment.content.isNotEmpty) Text(moment.content, style: const TextStyle(fontSize: 15)),
            if (moment.imagePaths.isNotEmpty) ...[
              const SizedBox(height: 12),
              moment.imagePaths.length == 1
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(moment.imagePaths.first, width: double.infinity, fit: BoxFit.cover),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                      itemCount: moment.imagePaths.length,
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(moment.imagePaths[index], fit: BoxFit.cover),
                      ),
                    ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () => appData.toggleLike(moment.id),
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null),
                  label: Text('${moment.likes.length}'),
                ),
                TextButton.icon(
                  onPressed: () => _showCommentDialog(context),
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('${moment.comments.length}'),
                ),
              ],
            ),
            if (moment.comments.isNotEmpty) ...[
              const Divider(),
              ...moment.comments.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(text: '${c.userName}: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        TextSpan(text: c.content, style: TextStyle(color: Colors.grey[800])),
                      ]),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final controller = TextEditingController();
    final appData = context.read<AppData>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('发表评论'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: '写下你的评论...'), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                appData.addComment(moment.id, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }
}
