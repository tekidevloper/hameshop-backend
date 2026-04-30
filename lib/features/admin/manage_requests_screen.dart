import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/request_service.dart';
import '../../models/request_model.dart';

class ManageRequestsScreen extends StatefulWidget {
  const ManageRequestsScreen({super.key});

  @override
  State<ManageRequestsScreen> createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen> {
  final RequestService _requestService = RequestService();
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestService.fetchAllRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manage_requests'.tr()),
      ),
      body: ValueListenableBuilder<List<RequestModel>>(
        valueListenable: _requestService.requests,
        builder: (context, requests, child) {
          if (requests.isEmpty && _requestService.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requests.isEmpty) {
            return Center(child: Text('no_requests_found'.tr()));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(request.status).withAlpha(25),
                    child: Icon(_getCategoryIcon(request.category), color: _getStatusColor(request.status)),
                  ),
                  title: Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${'from'.tr()}: ${request.userName} • ${DateFormat('MMM dd, HH:mm').format(request.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(request.status)),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${'category_label'.tr()}: ${request.category.toLowerCase().replaceAll(' ', '_').tr()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('${'message_label'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(request.message),
                          const Divider(height: 32),
                          if (request.adminResponse != null) ...[
                            Text('${'your_response'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            Text(request.adminResponse!),
                            const SizedBox(height: 16),
                          ],
                          Text('${'reply_update_status'.tr()}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _responseController,
                            decoration: InputDecoration(
                              hintText: 'enter_response'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _submitResponse(request, 'Responded'),
                                child: Text('send_response'.tr()),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _submitResponse(request, 'Closed'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                child: Text('close_request'.tr()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _submitResponse(RequestModel request, String status) async {
    if (_responseController.text.isEmpty && status == 'Responded') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('enter_response_error'.tr())));
      return;
    }

    final success = await _requestService.respondToRequest(
      request.id,
      _responseController.text,
      status,
    );

    if (success) {
      _responseController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('response_sent'.tr())));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('response_failed'.tr())));
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
