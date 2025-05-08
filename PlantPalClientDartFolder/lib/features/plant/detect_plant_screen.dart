import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:plant_pal_app/shared/services/plant_service.dart';

import '../../shared/models/plant_model.dart';
import '../../shared/services/auth_service.dart';

class AddPlantView extends StatefulWidget {
  const AddPlantView({super.key});

  @override
  State<AddPlantView> createState() => _AddPlantViewState();
}

class ResponseML {
  final String classML;
  final String realName;
  final String accuracy;

  ResponseML({
    required this.classML,
    required this.realName,
    required this.accuracy,
  });

  factory ResponseML.fromJson(Map<String, dynamic> json) {
    return ResponseML(
      classML: json['classML'] ?? '',
      realName: json['real_name'] ?? '',
      accuracy: json['accuracy'] ?? '',
    );
  }
}

class _AddPlantViewState extends State<AddPlantView> {
  XFile? _image;
  ResponseML? resultsML;
  Plant? resultsServer;
  bool isInfoLoading = true;
  bool notRecognisable = false;
  String clientText = "Is this really your plant?";

  @override
  void initState() {
    super.initState();
  }

  Future<void> recognizePlant() async {
    if (_image == null) return;
    await postData(_image!);
  }

  Future<void> postData(XFile file) async {
    final uri = Uri.parse('http://localhost:8080/predict/plant');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    final Map<String, dynamic> json = jsonDecode(responseBody);
    resultsML = ResponseML.fromJson(json);

    if (double.tryParse(resultsML?.accuracy ?? '-5') != null &&
        double.parse(resultsML!.accuracy) >= -3.5) {
      if (resultsML == null) return;
      resultsServer = await PlantService().fetchByMlid(resultsML!.classML);
    } else {
      setState(() {
        clientText = "We cannot recognize your flower";
        notRecognisable = true;
      });
    }

    setState(() {
      isInfoLoading = false;
    });
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = picked;
        isInfoLoading = true;
        notRecognisable = false;
        clientText = "Is this really your plant?";
      });
      await recognizePlant();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8BC183),
      body: SafeArea(
        child: Center(
          child: _image == null
              ? ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a photo'),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clientText,
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF789B2F),
                ),
              ),
              const SizedBox(height: 8),
              Image.file(
                File(_image!.path),
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 16),
              if (isInfoLoading)
                const CircularProgressIndicator()
              else if (!notRecognisable && resultsServer != null)
                Column(
                  children: [
                    Text(
                      resultsServer!.name,
                      style: TextStyle(fontSize: 24, color: Color(0xFF789B2F)),
                    ),
                    Text(
                      resultsServer!.description,
                      style: TextStyle(fontSize: 18, color: Color(0xFF789B2F)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, size: 50, color: Colors.green),
                          onPressed: () async {
                            await AuthService().addFlowerToUser(resultsServer!.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, size: 50, color: Colors.red),
                          onPressed: () {
                            // Отказ от распознанного растения, можно добавить действие
                          },
                        ),
                      ],
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: _pickImage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Repeat", style: TextStyle(fontSize: 20, color: Color(0xFF789B2F))),
                      SizedBox(width: 8),
                      Icon(Icons.refresh, color: Color(0xFF789B2F)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
