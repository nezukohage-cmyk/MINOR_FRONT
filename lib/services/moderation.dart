import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ModerationService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _loaded = false;

  /// Load model + labels.txt
  Future<void> loadModel() async {
    if (_loaded) return;

    // Load labels
    final labelsFile = File('assets/models/labels.txt');
    _labels = await labelsFile.readAsLines();

    // Create interpreter
    _interpreter = await Interpreter.fromAsset(
      'assets/models/model_unquant.tflite',
      options: InterpreterOptions()..threads = 2,
    );

    _loaded = true;
  }

  bool get isReady => _loaded;

  /// Classifies an image file using your TFLite model
  Future<Map<String, double>> classify(File imageFile) async {
    if (!_loaded) {
      throw Exception("Moderation model not loaded!");
    }

    // Decode image with package:image
    Uint8List raw = await imageFile.readAsBytes();
    img.Image? baseImage = img.decodeImage(raw);

    if (baseImage == null) {
      throw Exception("Failed to decode image.");
    }

    // Resize image to 224x224 (model input size)
    img.Image resized = img.copyResize(baseImage, width: 224, height: 224);

    // Prepare input tensor
    var input = List.generate(
      1,
          (_) => List.generate(
        224,
            (_) => List.generate(
          224,
              (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[0][y][x][0] = img.getRed(pixel) / 255.0;
        input[0][y][x][1] = img.getGreen(pixel) / 255.0;
        input[0][y][x][2] = img.getBlue(pixel) / 255.0;
      }
    }

    // Output tensor size = number of labels
    var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    // Run inference
    _interpreter!.run(input, output);

    // Build result as {label: probability}
    return {
      _labels[0]: output[0][0], // "Page"
      _labels[1]: output[0][1], // "Not Page"
    };
  }
}
