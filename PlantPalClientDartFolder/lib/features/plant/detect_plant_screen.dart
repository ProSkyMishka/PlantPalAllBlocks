import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  String clientText = "Это точно ваше растение?";

  @override
  void initState() {
    super.initState();
  }

  void resetState() {
    setState(() {
      _image = null;
      resultsML = null;
      resultsServer = null;
      isInfoLoading = true;
      notRecognisable = false;
      clientText = "Это точно ваше растение?";
    });
  }

  Future<void> recognizePlant() async {
    if (_image == null) return;
    await postData(_image!);
  }

  Future<void> postData(XFile file) async {
    final uri = Uri.parse('https://63b2-163-172-173-37.ngrok-free.app/predict/plant');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      try {
        final Map<String, dynamic> json = jsonDecode(responseBody);
        resultsML = ResponseML.fromJson(json);
        if (double.tryParse(resultsML!.accuracy) != null &&
            double.parse(resultsML!.accuracy) >= 0.5) {
          resultsServer = await PlantService().fetchByMlid(resultsML!.classML);
        } else {
          setState(() {
            clientText = "Мы не можем распознать Ваше растение";
            notRecognisable = true;
          });
        }
      } catch (e) {
        setState(() {
          clientText = "Error processing the response.";
          notRecognisable = true;
        });
      }
    } else {
      setState(() {
        clientText = "Не удалось получить данные от сервера. Попробуйте снова.";
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
        clientText = "Это точно ваше растение?";
      });
      await recognizePlant();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BC183),
      appBar: AppBar(
        backgroundColor: const Color(0xFF789B2F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('Добавить растение', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: _image == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Сфотайте свое растение",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF789B2F),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Открыть камеру', style: TextStyle(
                  color: Colors.white,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF789B2F),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clientText,
                style: const TextStyle(
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
                      style: const TextStyle(fontSize: 24, color: Color(0xFF789B2F)),
                    ),
                    Text(
                      resultsServer!.description,
                      style: const TextStyle(fontSize: 18, color: Color(0xFF789B2F)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, size: 50, color: Colors.green),
                          onPressed: () async {
                            await AuthService().addFlowerToUser(resultsServer!.id);
                            final result = await context.push('/plant/${resultsServer?.id}');
                            if (result == 'updated') {
                              context.pop('updated');
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, size: 50, color: Colors.red),
                          onPressed: resetState,
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
                      Text("Повторить", style: TextStyle(fontSize: 20, color: Color(0xFF789B2F))),
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
