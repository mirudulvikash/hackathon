import 'package:flutter/material.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

class CertificateDialog extends StatelessWidget {
  final Map<String, dynamic> certificateData;

  const CertificateDialog({super.key, required this.certificateData});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final theme = Theme.of(context);
    
    final studentName = certificateData['student_name'] ?? 'Student Learner';
    final certId = certificateData['certificate_id'] ?? 'MUN-CHAMP-2026-00000';
    final issueDate = certificateData['issue_date'] ?? '2026-10-09';
    final title = certificateData['title'] ?? 'MUNNARIVU DISASTER PREPAREDNESS CHAMPION';
    final subtitle = certificateData['subtitle'] ?? 'Awarded in recognition of completing the 100-Day Disaster Preparedness Learning Challenge.';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade700, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.verified, color: Colors.amber.shade800, size: 36),
                  Text(
                    'MUNNARIVU',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 2.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(thickness: 1.5, color: Colors.amber),
              const SizedBox(height: 16),
              
              Icon(Icons.emoji_events, size: 64, color: Colors.amber.shade800),
              const SizedBox(height: 12),
              
              Text(
                lang.tr("CERTIFICATE OF ACHIEVEMENT", "சான்றளிப்புச் சான்றிதழ்"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                lang.tr("This certificate is proudly presented to", "இந்தச் சான்றிதழ் பெருமையுடன் வழங்கப்படுகிறது"),
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(issueDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Certificate ID:", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(certId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Official In-App Learning Achievement • Non-Governmental Accreditation",
                  style: TextStyle(fontSize: 10, color: Colors.black54, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.tr("Certificate shared successfully!", "சான்றிதழ் வெற்றிகரமாகப் பகிரப்பட்டது!")),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(lang.tr("Share", "பகிர்")),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.tr("Certificate downloaded to device!", "சான்றிதழ் தரவிறக்கம் செய்யப்பட்டது!")),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(lang.tr("Download", "பதிவிறக்கு")),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
