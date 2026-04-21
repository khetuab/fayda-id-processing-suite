// views/form_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/id_card_model.dart';
import '../services/controller.dart';
import '../services/data.dart';

class FormPage extends StatefulWidget {
  final IDCardModel idData;
  FormPage({Key? key, required this.idData}) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final formController = FormController.instance;
  late final IDCardModel idData;
  final FormController controller = Get.find<FormController>();

  List<String> _getAllEnglishSubcities() {
    List<String> allSubcities = [];
    EthiopiaLocationData.regions.forEach((region, cities) {
      cities.forEach((city, subcities) {
        allSubcities.addAll(subcities);
      });
    });
    return allSubcities.toSet().toList(); // Remove duplicates
  }

  List<String> _getAllAmharicSubcities() {
    List<String> allSubcities = [];
    EthiopiaLocationData.amregions.forEach((region, cities) {
      cities.forEach((city, subcities) {
        allSubcities.addAll(subcities);
      });
    });
    return allSubcities.toSet().toList(); // Remove duplicates
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(

          title: Text(
            'Information Form',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[700],
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.cleaning_services),
              onPressed: formController.clearAllFields,
              tooltip: 'Clear All',
              color: Colors.white,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  _buildAmharicSection(),
                  SizedBox(height: 20),
                  _buildEnglishSection(),
                  SizedBox(height: 20),
                  _buildDateSection(context), // ADD THIS LINE
                  SizedBox(height: 20),
                  _buildExDateSection(context), // ADD THIS LINE
                  SizedBox(height: 20),
                  _buildIdentificationSection(),
                  SizedBox(height: 30),
                  _buildSubmitButton(widget.idData),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.purple[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700], size: 30),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Please fill all the required fields',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmharicSection() {
    return _buildSection(
      title: 'Amharic Information',
      icon: Icons.language,
      color: Colors.green,
      children: [
        _buildTextField(
          controller: formController.amName,
          focusNode: formController.focusNodes[2],
          label: 'Amharic Name',
          hint: 'Enter name in Amharic',
          icon: Icons.person,
          isRequired: false,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => formController.moveToNextField(0),
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'Amharic Country',
          controller: formController.amCountry,
          icon: Icons.map,
          items: EthiopiaLocationData.country,
          hint: 'Select or type Country',
          onChanged: (_) {},
          // Removed onChanged that was clearing other fields
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'Amharic Region',
          controller: formController.amRegion,
          icon: Icons.map,
          items: EthiopiaLocationData.getamRegions(),
          hint: 'Select or type region',
          onChanged: (_) {},
          // Removed onChanged that was clearing city and subcity
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'Amharic City',
          controller: formController.amCity,
          icon: Icons.location_city,
          // Show all cities regardless of selected region
          items: EthiopiaLocationData.getAllCitiesam(),
          hint: 'Select or type city',
          onChanged: (_) {},
          // Removed onChanged that was clearing subcity
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'Amharic Subcity',
          controller: formController.amSubcity,
          icon: Icons.location_on,
          onChanged: (_) {},
          items: _getAllAmharicSubcities(),
          hint: 'Select or type subcity',
          // Removed onChanged
        ),
      ],
    );
  }

  Widget _buildEnglishSection() {
    return _buildSection(
      title: 'English Information',
      icon: Icons.language,
      color: Colors.blue,
      children: [
        _buildTextField(
          controller: formController.englishName,
          focusNode: formController.focusNodes[0],
          label: 'English Name',
          hint: 'Enter name in English',
          icon: Icons.person,
          isRequired: false,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => formController.moveToNextField(0),
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'English Country',
          controller: formController.enCountry,
          icon: Icons.camera_outdoor_rounded,
          items: EthiopiaLocationData.countryen,
          hint: 'Select or type country',
          onChanged: (_) {},
          // Removed onChanged that was clearing other fields
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'English Region',
          controller: formController.enRegion,
          icon: Icons.map,
          items: EthiopiaLocationData.getRegions(),
          hint: 'Select or type region',
          onChanged: (_) {},
          // Removed onChanged that was clearing city and subcity
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'English City',
          controller: formController.enCity,
          icon: Icons.location_city,
          // Show all cities regardless of selected region
          items: EthiopiaLocationData.getAllCities(),
          hint: 'Select or type city',
          onChanged: (_) {},
          // Removed onChanged that was clearing subcity
        ),
        SizedBox(height: 12),
        _buildDropdownField(
          label: 'English Subcity',
          controller: formController.enSubcity,
          icon: Icons.location_on,
          // You might need to modify this to get all subcities
          // This depends on how your data is structured
          items: _getAllEnglishSubcities(),
          onChanged: (_) {},
          hint: 'Select or type subcity',
          // Removed onChanged
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.purple[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),

          ),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.blue[600])
                  : null,
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(controller.text) ? controller.text : null,
                isExpanded: true,
                hint: Text(
                  hint ?? 'Select $label',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.text = value;
                    onChanged(value);
                  }
                },
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[500]!),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Or type manually...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: false,
            ),
            onChanged: (val) => onChanged(val),
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  // Add this widget method in FormPage class
  Widget _buildDateSection(BuildContext context) {
    return _buildSection(
      title: 'Issue Date Information',
      icon: Icons.calendar_today,
      color: Colors.purple,
      children: [
        _buildDatePickerField(
          controller: formController.gregorianIssueDate,
          focusNode: formController.focusNodes[10],
          label: 'Gregorian Date (YYYY/MM/DD)',
          hint: 'Select Gregorian date',
          icon: Icons.calendar_today,
          onTap: () => _showGregorianDatePicker(context),
        ),
        SizedBox(height: 12),
        _buildDatePickerField(
          controller: formController.ethiopianIssueDate,
          focusNode: formController.focusNodes[11],
          label: 'Ethiopian Date (YYYY/Mon/DD)',
          hint: 'Select Ethiopian date',
          icon: Icons.calendar_today,
          onTap: () => _showEthiopianDatePicker(context),
        ),
      ],
    );
  }

  Widget _buildExDateSection(BuildContext context) {
    return _buildSection(
      title: 'Expire Date Information',
      icon: Icons.calendar_today,
      color: Colors.purple,
      children: [
        _buildDatePickerField(
          controller: formController.gregorianExDate,
          focusNode: formController.focusNodes[12],
          label: 'Gregorian Date (YYYY/MM/DD)',
          hint: 'Select Gregorian date',
          icon: Icons.calendar_today,
          onTap: () => _showExGregorianDatePicker(context),
        ),
        SizedBox(height: 12),
        _buildDatePickerField(
          controller: formController.ethiopianExDate,
          focusNode: formController.focusNodes[13],
          label: 'Ethiopian Date (YYYY/Mon/DD)',
          hint: 'Select Ethiopian date',
          icon: Icons.calendar_today,
          onTap: () => _showExEthiopianDatePicker(context),
        ),
      ],
    );
  }

  Widget _buildIdentificationSection() {
    return _buildSection(
      title: 'Identification',
      icon: Icons.badge,
      color: Colors.orange,
      children: [
        _buildTextField(
          controller: formController.fin,
          focusNode: formController.focusNodes[14],
          label: 'FIN Number',
          hint: 'Enter FIN number',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => formController.moveToNextField(8),
        ),
        SizedBox(height: 12),
        _buildTextField(
          controller: formController.fan,
          focusNode: formController.focusNodes[15],
          label: 'FAN Number',
          hint: 'Enter FAN number',
          icon: Icons.numbers,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => formController.moveToNextField(8),
        ),
        SizedBox(height: 12),
        _buildTextField(
          controller: formController.fon,
          focusNode: formController.focusNodes[16],
          label: 'Phone Number',
          hint: 'Enter Phone number',
          icon: Icons.phone,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => formController.moveToNextField(8),
        ),

        SizedBox(height: 12),
        _buildTextField(
          controller: formController.serialNo,
          focusNode: formController.focusNodes[9],
          label: 'Serial Number',
          hint: 'Enter serial number',
          icon: Icons.confirmation_number,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            formController.moveToNextField(9);
            formController.submitForm(widget.idData);
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton( IDCardModel idData) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: controller.isLoading
            ? null
            : () async {
          await controller.submitForm(widget.idData);
          setState(() {}); // refresh UI
          Get.back();
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: formController.isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Processing...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 20,color: Colors.white,),
            SizedBox(width: 10),
            Text(
              'Submit Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ],
        ),
      ),
    ));
  }

// Add this widget method
  Widget _buildDatePickerField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.purple[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.purple[600]),
      ),
    );
  }

// Add these date picker methods
  void _showGregorianDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700]!,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      formController.gregorianIssueDate.text =
      "${picked.year}/${months[picked.month - 1]}/${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _showExGregorianDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700]!,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      formController.gregorianExDate.text =
      "${picked.year}/${months[picked.month - 1]}/${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _showEthiopianDatePicker(BuildContext context) {
    // Ethiopian months
    final List<String> ethiopianMonths = [
      'Meskerem', 'Tikimit', 'Hidar', 'Tahesas', 'Tir', 'Yekatit',
      'Megabit', 'Miazia', 'Genbot', 'Sene', 'Hamle', 'Nehase', 'Pagume'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = 2015;
        String selectedMonth = 'Meskerem';
        int selectedDay = 1;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Ethiopian Date', style: TextStyle(color: Colors.purple[700])),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year Picker
                    Row(
                      children: [
                        Text('Year: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedYear,
                            isExpanded: true,
                            items: List.generate(100, (index) => 2000 + index)
                                .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text('$year'),
                            )).toList(),
                            onChanged: (value) => setState(() => selectedYear = value!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Month Picker
                    Row(
                      children: [
                        Text('Month: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedMonth,
                            isExpanded: true,
                            items: ethiopianMonths.map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            )).toList(),
                            onChanged: (value) => setState(() => selectedMonth = value!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Day Picker
                    Row(
                      children: [
                        Text('Day: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedDay,
                            isExpanded: true,
                            items: List.generate(30, (index) => index + 1)
                                .map((day) => DropdownMenuItem(
                              value: day,
                              child: Text('$day'),
                            )).toList(),
                            onChanged: (value) => setState(() => selectedDay = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Get month number (1-13) for Ethiopian calendar
                    final monthNumber = (ethiopianMonths.indexOf(selectedMonth) + 1).toString().padLeft(2, '0');
                    formController.ethiopianIssueDate.text =
                    "$selectedYear/$monthNumber/${selectedDay.toString().padLeft(2, '0')}";
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                  child: Text('Select', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExEthiopianDatePicker(BuildContext context) {
    // Ethiopian months
    final List<String> ethiopianMonths = [
      'Meskerem', 'Tikimit', 'Hidar', 'Tahesas', 'Tir', 'Yekatit',
      'Megabit', 'Miazia', 'Genbot', 'Sene', 'Hamle', 'Nehase', 'Pagume'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = 2015;
        String selectedMonth = 'Meskerem';
        int selectedDay = 1;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Ethiopian Date', style: TextStyle(color: Colors.purple[700])),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year Picker
                    Row(
                      children: [
                        Text('Year: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedYear,
                            isExpanded: true,
                            items: List.generate(100, (index) => 2000 + index)
                                .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text('$year'),
                            )).toList(),
                            onChanged: (value) => setState(() => selectedYear = value!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Month Picker
                    Row(
                      children: [
                        Text('Month: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedMonth,
                            isExpanded: true,
                            items: ethiopianMonths.map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            )).toList(),
                            onChanged: (value) => setState(() => selectedMonth = value!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Day Picker
                    Row(
                      children: [
                        Text('Day: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selectedDay,
                            isExpanded: true,
                            items: List.generate(30, (index) => index + 1)
                                .map((day) => DropdownMenuItem(
                              value: day,
                              child: Text('$day'),
                            )).toList(),
                            onChanged: (value) => setState(() => selectedDay = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Get month number (1-13) for Ethiopian calendar
                    final monthNumber = (ethiopianMonths.indexOf(selectedMonth) + 1).toString().padLeft(2, '0');
                    formController.ethiopianExDate.text =
                    "$selectedYear/$monthNumber/${selectedDay.toString().padLeft(2, '0')}";
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                  child: Text('Select', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
