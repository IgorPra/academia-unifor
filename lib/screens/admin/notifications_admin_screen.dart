import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:academia_unifor/models/notifications.dart';
import 'package:academia_unifor/widgets.dart';

class NotificationAdminScreen extends StatefulWidget {
  const NotificationAdminScreen({super.key});

  @override
  State<NotificationAdminScreen> createState() =>
      _NotificationAdminScreenState();
}

class _NotificationAdminScreenState extends State<NotificationAdminScreen> {
  List<Notifications> allNotifications = [];
  List<Notifications> filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final jsonStr = await rootBundle.loadString('assets/mocks/notification.json');
    final data = json.decode(jsonStr) as List;
    final loaded = data.map((e) => Notifications.fromJson(e)).toList();
    setState(() {
      allNotifications = loaded;
      filteredNotifications = loaded;
    });
  }

  void _filter(String query) {
    setState(() {
      filteredNotifications = allNotifications
          .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _updateNotification(Notifications updated) {
    setState(() {
      final index = allNotifications.indexWhere((n) => n.id == updated.id);
      if (index != -1) {
        allNotifications[index] = updated;
        filteredNotifications = List.from(allNotifications);
      }
    });
  }

  void _deleteNotification(Notifications notification) {
    setState(() {
      allNotifications.removeWhere((n) => n.id == notification.id);
      filteredNotifications = List.from(allNotifications);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: AdminConvexBottomBar(
          currentIndex: 4,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: SearchAppBar(onSearchChanged: _filter, showChatIcon: false),
            body: NotificationAdminBody(
              notifications: filteredNotifications,
              onTapNotification: (notification) async {
                final updated = await Navigator.push<Notifications?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditNotificationScreen(
                      notification: notification,
                    ),
                  ),
                );

                if (updated != null) {
                  _updateNotification(updated);
                }
              },
              onDeleteNotification: _deleteNotification,
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationAdminBody extends StatelessWidget {
  final List<Notifications> notifications;
  final void Function(Notifications) onDeleteNotification;
  final void Function(Notifications) onTapNotification;

  const NotificationAdminBody({
    super.key,
    required this.notifications,
    required this.onDeleteNotification,
    required this.onTapNotification,
  });

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: notifications.isEmpty
          ? const Center(child: Text('Nenhuma notificação encontrada.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(notif.title),
                    subtitle: Text(notif.description),
                    trailing: Text(
                      _formatDate(notif.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => onTapNotification(notif),
                  ),
                );
              },
            ),
    );
  }
}

class EditNotificationScreen extends StatefulWidget {
  final Notifications notification;

  const EditNotificationScreen({super.key, required this.notification});

  @override
  State<EditNotificationScreen> createState() => _EditNotificationScreenState();
}

class _EditNotificationScreenState extends State<EditNotificationScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.notification.title);
    descController = TextEditingController(text: widget.notification.description);
  }

  void _saveChanges() {
    final updated = Notifications(
      id: widget.notification.id,
      title: titleController.text,
      description: descController.text,
      createdAt: widget.notification.createdAt,
    );
    Navigator.pop(context, updated);
  }

  void _delete() {
    Navigator.pop(context); // Pode passar null para indicar exclusão se preferir
    // A deleção real deve ser tratada no parent após Navigator.pop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Notificação"),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete),
              label: const Text('Apagar Notificação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
