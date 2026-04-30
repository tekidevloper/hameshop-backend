import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/product.dart';
import 'product_service.dart';

class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  // Replace with actual API key or use environment variable
  static const String _apiKey = 'AIzaSyDB1wOusKZl4hVCTPEocEmrnJFzPOG6n6Q'; 

  late final GenerativeModel _model;
  ChatSession? _chatSession;

  void init() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
    _chatSession = _model.startChat();
  }

  Future<String> getResponse(String userMessage) async {
    if (_chatSession == null) {
      init();
    }

    final modelsToTry = [
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-pro',
    ];

    String? lastError;

    for (final modelName in modelsToTry) {
      try {
        final products = ProductService().products.value;
        final systemPrompt = _buildSystemPrompt(products);
        
        print('AIChatService: Attempting to generate content with $modelName');

        final modelWithContext = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          systemInstruction: Content.system(systemPrompt),
        );

        final response = await modelWithContext.generateContent([
          Content.text(userMessage),
        ]);

        if (response.text != null) {
          print('AIChatService: Successfully received response from $modelName');
          return response.text!;
        }
      } catch (e) {
        lastError = e.toString();
        print('AIChatService: Failed for $modelName - $e');
        // Continue to the next model in the loop
      }
    }

    return 'I am sorry, I am currently unable to connect to the AI service. Error: $lastError';
  }

  String _buildSystemPrompt(List<Product> products) {
    String productInfo = products.map((p) => 
      '- ${p.name}: \$${p.price}. Category: ${p.category}. Description: ${p.description}'
    ).join('\n');

    return '''
You are the HameShop AI assistant, a helpful and professional customer support bot for an e-commerce app in Ethiopia.
Your goal is to answer user questions about HameShop and its products.

HameShop Details:
- Owner/Admin: Hamee Asdsach (Telegram: @Hameee40)
- Delivery: Across Ethiopia, usually 1-3 days.
- Payments: Chapa, Bank Transfer (CBE, Awash, Dashen, Abyssinia, etc.), or via Telegram.

Available Products:
$productInfo

Instructions:
1. Always be polite and professional.
2. Answer in the same language as the user (English or Amharic).
3. If the user asks about a specific product, use the provided list to give accurate details.
4. If a product is not in the list, politely say you don't have information about it but can help with others.
5. If the user needs direct support, refer them to @Hameee40 on Telegram.
6. Keep responses concise and helpful.
7. Use Ethiopian context where appropriate.
''';
  }
}
