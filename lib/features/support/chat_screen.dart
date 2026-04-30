import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/request_service.dart';
import '../../services/ai_chat_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your HameShop AI assistant. How can I help you today?',
      'isUser': false,
      'time': DateTime.now(),
    },
  ];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': true,
        'time': DateTime.now(),
      });
      _controller.clear();
    });

    _scrollToBottom();

    // Alert Admin in background if needed
    _alertAdminIfNeeded(userMessage);

    // Call Real AI Service
    setState(() {
      _isLoading = true;
    });

    AIChatService().getResponse(userMessage).then((response) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add({
          'text': response,
          'isUser': false,
          'time': DateTime.now(),
        });
      });
      _scrollToBottom();
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add({
          'text': 'I am sorry, I encountered an error: $error',
          'isUser': false,
          'time': DateTime.now(),
        });
      });
      _scrollToBottom();
    });
  }

  bool _isAmharic(String text) {
    return RegExp(r'[\u1200-\u137F]').hasMatch(text);
  }

  Future<void> _alertAdminIfNeeded(String query) async {
    final q = query.toLowerCase();

    bool needsSupport = q.contains('contact') || 
                        q.contains('admin') || 
                        q.contains('support') || 
                        q.contains('help') ||
                        q.contains('እርዳታ') ||
                        q.contains('አግኝ') ||
                        q.contains('አስተዳዳሪ');

    if (needsSupport) {
      await RequestService().createRequest(
        'AI Chat Support Alert',
        'User is requesting support in AI Chat. Last message: "$query"',
        'Support'
      );
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ai_chat'.tr(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.smart_toy_outlined, color: colorScheme.onPrimary),
            onPressed: () async {
              final Uri url = Uri.parse('https://t.me/HameShopBot');
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Premium Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.05 : 0.2),
                    colorScheme.surface,
                    colorScheme.primary.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.1 : 0.3),
                  ],
                ),
              ),
            ),
          ),
          // Abstract Shapes for Blur Context
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut).fadeIn(),
          
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),
              if (_isLoading) _buildLoadingBubble(),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isUser = msg['isUser'] as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.smart_toy_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
            ).animate().scale(duration: 300.ms),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.15) 
                        : Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.4 : 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    msg['text'],
                    style: _isAmharic(msg['text'])
                        ? GoogleFonts.notoSansEthiopic(
                            color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          )
                        : GoogleFonts.outfit(
                            color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: isUser ? 0.1 : -0.1, end: 0),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 18, color: Theme.of(context).colorScheme.primary),
            ).animate().scale(duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: _isAmharic(_controller.text)
                          ? GoogleFonts.notoSansEthiopic(
                              fontSize: 15, 
                              color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white)
                          : GoogleFonts.outfit(
                              fontSize: 15, 
                              color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white),
                      onChanged: (text) => setState(() {}), // Refresh to update font dynamically
                      decoration: InputDecoration(
                        hintText: 'type_message'.tr(),
                        hintStyle: TextStyle(
                          color: (Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white54),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ).animate().scale(duration: 200.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.smart_toy_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
          ).animate().scale(duration: 300.ms),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.4 : 0.2),
                      width: 1,
                    ),
                  ),
                child: SizedBox(
                  width: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle))
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(duration: 400.ms, begin: const Offset(1, 1), end: const Offset(1.5, 1.5))
                          .then()
                          .scale(duration: 400.ms, begin: const Offset(1.5, 1.5), end: const Offset(1, 1)),
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle))
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(delay: 200.ms, duration: 400.ms, begin: const Offset(1, 1), end: const Offset(1.5, 1.5))
                          .then()
                          .scale(duration: 400.ms, begin: const Offset(1.5, 1.5), end: const Offset(1, 1)),
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle))
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(delay: 400.ms, duration: 400.ms, begin: const Offset(1, 1), end: const Offset(1.5, 1.5))
                          .then()
                          .scale(duration: 400.ms, begin: const Offset(1.5, 1.5), end: const Offset(1, 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
