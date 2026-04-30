import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChapaPaymentScreen extends StatefulWidget {
  final double amount;
  final String productName;

  const ChapaPaymentScreen({
    super.key,
    required this.amount,
    required this.productName,
  });

  @override
  State<ChapaPaymentScreen> createState() => _ChapaPaymentScreenState();
}

class _ChapaPaymentScreenState extends State<ChapaPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Configure Chapa with your key (User should replace this)
    Chapa.configure(privateKey: 'CHASECK_TEST-1234567890abcdef1234567890abcdef');
  }

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a unique transaction reference
      final txRef = 'TX-${const Uuid().v4()}';

      await Chapa.getInstance.startPayment(
        context: context,
        currency: 'ETB',
        amount: widget.amount.toString(),
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        txRef: txRef,
        title: 'Payment for ${widget.productName}',
        description: 'Payment for ${widget.productName} via HameShop',
        onInAppPaymentSuccess: (successMsg) {
          if (!mounted) return;
          // Verify payment here if needed
          _handlePaymentSuccess(successMsg);
        },
        onInAppPaymentError: (errorMsg) {
          if (!mounted) return;
          _handlePaymentError(errorMsg);
        },
      );
    } catch (e) {
      if (mounted) {
        _handlePaymentError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePaymentSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('Your payment was processed successfully.\nRef: $message'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close payment screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Amount to Pay: ${widget.amount} ETB',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                focusNode: _firstNameFocus,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter first name' : null,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                focusNode: _lastNameFocus,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter last name' : null,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Please enter valid email'
                    : null,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onFieldSubmitted: (_) => _startPayment(),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _startPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green, // Chapa brand color ish
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Pay with Chapa'),
                    ),
                const SizedBox(height: 10,),
                const Text("Supported Banks: CBE, Awash, Dashen, Telebirr, etc.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),)
            ],
          ),
        ),
      ),
    );
  }
}
