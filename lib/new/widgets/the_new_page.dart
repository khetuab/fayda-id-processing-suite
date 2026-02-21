// pages/photo_size_settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/controller.dart';

class PhotoSizeSettingsPage extends StatefulWidget {
  const PhotoSizeSettingsPage({Key? key}) : super(key: key);

  @override
  State<PhotoSizeSettingsPage> createState() => _PhotoSizeSettingsPageState();
}

class _PhotoSizeSettingsPageState extends State<PhotoSizeSettingsPage> {
  final FormController formController = Get.find<FormController>();

  late double _currentWidth;
  late double _currentHeight;

  @override
  void initState() {
    super.initState();
    _currentWidth = formController.widthOfPhoto.value;
    _currentHeight = formController.heightOfPhoto.value;
  }

  void _updateWidth(double value) {
    setState(() {
      _currentWidth = value;
    });
    formController.widthOfPhoto.value = value;
  }

  void _updateHeight(double value) {
    setState(() {
      _currentHeight = value;
    });
    formController.heightOfPhoto.value = value;
  }

  void _resetToDefault() {
    setState(() {
      _currentWidth = 0.32;
      _currentHeight = 0.35;
    });
    formController.widthOfPhoto.value = 0.32;
    formController.heightOfPhoto.value = 0.35;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Size Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefault,
            tooltip: 'Reset to Default',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Width Slider
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Width',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentWidth.toStringAsFixed(3),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _currentWidth,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100, // This gives 0.01 increments
                      label: _currentWidth.toStringAsFixed(3),
                      onChanged: _updateWidth,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blue.shade100,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('0.0', style: TextStyle(color: Colors.grey)),
                        Text('1.0', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Height Slider
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Height',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentHeight.toStringAsFixed(3),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _currentHeight,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100, // This gives 0.01 increments
                      label: _currentHeight.toStringAsFixed(3),
                      onChanged: _updateHeight,
                      activeColor: Colors.green,
                      inactiveColor: Colors.green.shade100,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('0.0', style: TextStyle(color: Colors.grey)),
                        Text('1.0', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 20),

            // Current Values Display
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Current Width',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _currentWidth.toStringAsFixed(3),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Current Height',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _currentHeight.toStringAsFixed(3),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Reset Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _resetToDefault,
          icon: const Icon(Icons.restore),
          label: const Text('Reset to Default Values'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}