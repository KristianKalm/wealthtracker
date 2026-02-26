import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:browser_image_compression/browser_image_compression.dart';
import '../theme/KrypticColors.dart';

class KrypticImagePickerView extends StatefulWidget {
  final double radius;
  final String placeholder;
  final Uint8List? imageBytes;
  final void Function(Uint8List file)? onImageSelected;

  const KrypticImagePickerView({super.key, this.radius = 200, this.placeholder = 'assets/images/placeholder.png', this.imageBytes, this.onImageSelected});

  @override
  State<KrypticImagePickerView> createState() => _KrypticImagePickerViewState();

  static ImageProvider imageProvider(Uint8List? bytes) {
    return bytes != null && bytes.isNotEmpty
        ? MemoryImage(bytes)
        : const AssetImage('assets/images/placeholder.png');
  }
}

class _KrypticImagePickerViewState extends State<KrypticImagePickerView> {
  Future<void> _uploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final colors = KrypticColors(Theme.of(context).brightness == Brightness.dark);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: colors.warningColor,
          toolbarWidgetColor: colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(title: 'Cropper', aspectRatioPresets: [CropAspectRatioPreset.square]),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: CropperSize(
            width: (MediaQuery.of(context).size.width * 0.8).clamp(200, 520).toInt(),
            height: (MediaQuery.of(context).size.height * 0.7).clamp(200, 520).toInt(),
          ),
        ),
      ],
    );
    if (croppedFile == null) return;
    final original = await XFile(croppedFile.path);
    final compressed = await resizeXFile(original);
    widget.onImageSelected?.call(compressed);
  }

  Future<Uint8List> resizeXFile(XFile xfile, {int maxSide = 1000, int quality = 85}) async {
    if (kIsWeb) {
      final name = xfile.name;
      final bytes = await xfile.readAsBytes();
      final mime = xfile.mimeType ?? 'image/jpeg';

      final options = Options(maxSizeMB: 1, maxWidthOrHeight: maxSide.toDouble(), initialQuality: quality.toDouble(), useWebWorker: true);
      final result = await BrowserImageCompression.compressImage(name, bytes, mime, options);
      return result;
    } else {
      final bytes = await xfile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Invalid image');

      double scale = 1.0;
      if (image.width > image.height && image.width > maxSide) {
        scale = maxSide / image.width;
      } else if (image.height >= image.width && image.height > maxSide) {
        scale = maxSide / image.height;
      }

      final resized = img.copyResize(image, width: (image.width * scale).toInt(), height: (image.height * scale).toInt());

      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = widget.imageBytes;
    return GestureDetector(
      onTap: _uploadImage,
      child: CircleAvatar(radius: widget.radius, backgroundImage: KrypticImagePickerView.imageProvider(img)),
    );
  }
}
