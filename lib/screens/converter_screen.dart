// screens/converter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _temperatureController = TextEditingController();
  String _selectedConversion = 'Fahrenheit to Celsius';
  double? _convertedValue;
  List<String> _history = [];

  final List<String> _conversionOptions = [
    'Fahrenheit to Celsius',
    'Celsius to Fahrenheit',
  ];

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  void _convertTemperature() {
    final String inputText = _temperatureController.text.trim();
    if (inputText.isEmpty) {
      _showErrorDialog('Please enter a temperature value');
      return;
    }

    final double? inputValue = double.tryParse(inputText);
    if (inputValue == null) {
      _showErrorDialog('Please enter a valid number');
      return;
    }

    double result;
    String historyEntry;

    if (_selectedConversion == 'Fahrenheit to Celsius') {
      // °C = (°F - 32) x 5/9
      result = (inputValue - 32) * 5 / 9;
      historyEntry = 'F to C: ${inputValue.toStringAsFixed(1)} ➜ ${result.toStringAsFixed(1)}';
    } else {
      // °F = °C x 9/5 + 32
      result = inputValue * 9 / 5 + 32;
      historyEntry = 'C to F: ${inputValue.toStringAsFixed(1)} ➜ ${result.toStringAsFixed(1)}';
    }

    setState(() {
      _convertedValue = result;
      _history.insert(0, historyEntry); // Add to top of history
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Converter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _buildPortraitLayout();
          } else {
            return _buildLandscapeLayout();
          }
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConversionSection(),
          const SizedBox(height: 20),
          _buildTemperatureInput(),
          const SizedBox(height: 20),
          _buildConvertButton(),
          const SizedBox(height: 20),
          _buildResult(),
          const SizedBox(height: 20),
          Expanded(child: _buildHistory()),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildConversionSection(),
                const SizedBox(height: 16),
                _buildTemperatureInput(),
                const SizedBox(height: 16),
                _buildConvertButton(),
                const SizedBox(height: 16),
                _buildResult(),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: _buildHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversion:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ..._conversionOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedConversion,
                onChanged: (String? value) {
                  setState(() {
                    _selectedConversion = value!;
                    _convertedValue = null; // Clear previous result
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter temperature',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              '=',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Container(
              width: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[100],
              ),
              child: Text(
                _convertedValue?.toStringAsFixed(1) ?? '',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _convertTemperature,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: const Text(
          'CONVERT',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_convertedValue == null) return const SizedBox.shrink();

    final inputValue = double.tryParse(_temperatureController.text) ?? 0;
    final fromUnit = _selectedConversion == 'Fahrenheit to Celsius' ? 'F' : 'C';
    final toUnit = _selectedConversion == 'Fahrenheit to Celsius' ? 'C' : 'F';

    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '$fromUnit to $toUnit: ${inputValue.toStringAsFixed(1)} ➜ ${_convertedValue!.toStringAsFixed(1)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'History of conversions made in this execution\n(most recent at the top)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _history.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No conversions yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _history[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                        dense: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}