import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/app_colors.dart';
import '../../models/event.dart';
import 'dart:io';
import '../../providers/payment_provider.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final Event event;
  final String registrationId;

  const PaymentScreen({
    super.key,
    required this.event,
    required this.registrationId, required Null Function(File file) onPaymentProofUploaded,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: const Text('Payment Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Transfer Details',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.bankDetails,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Payment Proof',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.add_photo_alternate, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _selectedImage == null
                    ? null
                    : _submitPayment,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Payment Proof'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);
    try {
      if (widget.event.organizerWhatsApp.isNotEmpty) {
        final whatsappUrl = Uri.parse(
            'https://wa.me/${widget.event.organizerWhatsApp}?text=Payment proof for event: ${widget.event.name}');
        await Share.shareXFiles(
          [XFile(_selectedImage!.path)],
          text:
              'Payment proof for event: ${widget.event.name}\nAmount: \$${widget.event.entryFee}',
        );
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl);
        }
      } else if (widget.event.organizerEmail.isNotEmpty) {
        final emailUri = Uri(
          scheme: 'mailto',
          path: widget.event.organizerEmail,
          query: 'subject=Payment proof for ${widget.event.name}',
        );
        await Share.shareXFiles(
          [XFile(_selectedImage!.path)],
          text:
              'Payment proof for event: ${widget.event.name}\nAmount: \$${widget.event.entryFee}',
        );
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        }
      }

      // Create pending payment record
      await Provider.of<PaymentProvider>(context, listen: false)
          .submitPaymentProof(
        eventId: widget.event.id,
        registrationId: widget.registrationId,
        proofImage: _selectedImage!,
        amount: widget.event.entryFee!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment proof submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
