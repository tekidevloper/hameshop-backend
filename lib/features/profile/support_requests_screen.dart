import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../services/request_service.dart';
import '../../models/request_model.dart';

class SupportRequestsScreen extends StatefulWidget {
  const SupportRequestsScreen({super.key});

  @override
  State<SupportRequestsScreen> createState() => _SupportRequestsScreenState();
}

class _SupportRequestsScreenState extends State<SupportRequestsScreen> {
  final RequestService _requestService = RequestService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'Support';

  @override
  void initState() {
    super.initState();
    _requestService.fetchMyRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('support_requests'.tr()),
      ),
      body: ValueListenableBuilder<List<RequestModel>>(
        valueListenable: _requestService.requests,
        builder: (context, requests, child) {
          if (requests.isEmpty && _requestService.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNewRequestForm(),
                      const SizedBox(height: 32),
                      Text(
                        'recent_requests'.tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (requests.isEmpty)
                        Center(child: Text('no_requests_yet'.tr())),
                    ],
                  ),
                ),
              ),
              if (requests.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildRequestCard(requests[index]),
                      childCount: requests.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewRequestForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('new_request'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'category_label'.tr(), border: const OutlineInputBorder()),
              items: ['Support', 'Product Inquiry', 'Order Issue', 'Other'].map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat.toLowerCase().replaceAll(' ', '_').tr()));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'title_label'.tr(), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'message_label'.tr(), border: const OutlineInputBorder()),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text('submit_request'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    final statusColor = _getStatusColor(request.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(_getCategoryIcon(request.category), color: statusColor),
        ),
        title: Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${request.category} • ${DateFormat('MMM dd').format(request.createdAt)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.status.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${'message_label'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(request.message),
                if (request.adminResponse != null) ...[
                  const Divider(height: 32),
                  Text('${'admin_response'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text(request.adminResponse!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('fill_all_fields'.tr())));
      return;
    }

    final success = await _requestService.createRequest(
      _titleController.text,
      _messageController.text,
      _selectedCategory,
    );

    if (success) {
      _titleController.clear();
      _messageController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('request_submitted'.tr())));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('request_failed'.tr())));
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.orange;
      case 'responded': return Colors.blue;
      case 'closed': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Support': return Icons.support_agent;
      case 'Product Inquiry': return Icons.help_outline;
      case 'Order Issue': return Icons.shopping_basket;
      default: return Icons.message;
    }
  }
}
