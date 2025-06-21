import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({
    super.key,
    required this.onImage,
  });

  final Function(InputImage inputImage) onImage;

  @override
  State<CameraWidget> createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner_outlined),
          SizedBox(
            width: 10,
          ),
          Text('Begleitschein scannen'),
        ],
      ),
      onPressed: () => getImage(ImageSource.camera),
    );
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.pickImage(
      source: source,
    );
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _processFile(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}
