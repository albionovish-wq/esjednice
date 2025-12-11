import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';

class UploadDokumentWidget extends ConsumerStatefulWidget {
  final String sjednicaId;
  final String korisnikId;
  final VoidCallback onUploadComplete;

  const UploadDokumentWidget({
    Key? key,
    required this.sjednicaId,
    required this.korisnikId,
    required this.onUploadComplete,
  }) : super(key: key);

  @override
  ConsumerState<UploadDokumentWidget> createState() =>
      _UploadDokumentWidgetState();
}

class _UploadDokumentWidgetState extends ConsumerState<UploadDokumentWidget> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  void _selectFile() async {
    // Note: For web, you'd use file_picker package
    // For now, showing the UI structure
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datotečni odabir nije dostupan u ovom okruženju'),
      ),
    );
  }

  void _uploadFile() async {
    if (_selectedFile == null) {
      setState(() => _errorMessage = 'Molimo odaberite datoteku');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Upload logic would go here
      // This is a placeholder for the actual upload
      setState(() {
        _uploadProgress = 0.5;
      });

      // Simulate upload
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dokument je uspješno učitan')),
        );
        widget.onUploadComplete();
        _resetForm();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Greška pri učitavanju: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedFile = null;
      _uploadProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesign.spacingL),
      decoration: BoxDecoration(
        color: AppDesign.white,
        borderRadius: BorderRadius.circular(AppDesign.cardRadius),
        border: Border.all(color: AppDesign.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Učitaj dokument (Zapisnik)',
            style: AppDesign.cardTitle,
          ),
          const SizedBox(height: AppDesign.spacingL),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDesign.spacingM),
              decoration: BoxDecoration(
                color: AppDesign.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                border: Border.all(color: AppDesign.errorRed),
              ),
              child: Text(
                _errorMessage!,
                style: AppDesign.bodyText.copyWith(color: AppDesign.errorRed),
              ),
            ),
            const SizedBox(height: AppDesign.spacingM),
          ],
          if (_selectedFile != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDesign.spacingM),
              decoration: BoxDecoration(
                color: AppDesign.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                border: Border.all(color: AppDesign.successGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        color: AppDesign.successGreen,
                      ),
                      const SizedBox(width: AppDesign.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFile!.path.split('/').last,
                              style: AppDesign.bodyText,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                              style: AppDesign.bodyTextSmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _resetForm,
                      ),
                    ],
                  ),
                  if (_isUploading) ...[
                    const SizedBox(height: AppDesign.spacingM),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDesign.buttonRadius),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 6,
                        backgroundColor: AppDesign.borderGray,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppDesign.successGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDesign.spacingS),
                    Text(
                      '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: AppDesign.bodyTextSmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDesign.spacingL),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppDesign.spacingL,
                horizontal: AppDesign.spacingM,
              ),
              decoration: BoxDecoration(
                color: AppDesign.lightGray,
                borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                border: Border.all(
                  color: AppDesign.borderGray,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppDesign.primaryBlue,
                  ),
                  const SizedBox(height: AppDesign.spacingM),
                  Text(
                    'Povucite datoteku ili kliknite za odabir',
                    style: AppDesign.bodyText,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDesign.spacingS),
                  Text(
                    'PDF, DOCX ili DOC do 50 MB',
                    style: AppDesign.bodyTextSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesign.spacingL),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isUploading ? null : _selectFile,
                child: const Text('Odaberi datoteku'),
              ),
              const SizedBox(width: AppDesign.spacingM),
              ElevatedButton(
                onPressed: _isUploading || _selectedFile == null
                    ? null
                    : _uploadFile,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Učitaj dokument'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
