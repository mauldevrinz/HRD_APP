import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../pages/user_profile_provider.dart';

class ProfileAvatar extends StatefulWidget {
  final double size;
  final bool editable;

  const ProfileAvatar({
    Key? key,
    this.size = 100,
    this.editable = false,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Show source selection
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final provider = context.read<UserProfileProvider>();
      final imageFile = File(image.path);
      final url = await provider.uploadProfilePhoto(imageFile);

      setState(() => _isUploading = false);

      if (!mounted) return;

      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengupload foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        final photoUrl = provider.userProfile?.photoUrl;

        return Stack(
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _isUploading
                    ? Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: widget.size * 0.6,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: widget.size * 0.6,
                              color: Colors.grey[600],
                            ),
                          ),
              ),
            ),
            if (widget.editable)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
