// new/widgets/background_template_selector.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/background_template_controller.dart';

class BackgroundTemplateSelector extends StatelessWidget {
  const BackgroundTemplateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BackgroundTemplateController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.style, color: const Color(0xFF0066FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'Background Templates',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Template Selection Grid
          Obx(() => Column(
            children: [
              // Template selector row
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: BackgroundTemplateController.totalTemplates,
                  itemBuilder: (context, index) {
                    final isSelected = controller.selectedTemplate.value == index;

                    return GestureDetector(
                      onTap: () => controller.setTemplate(index),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0066FF)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(11),
                                ),
                                child: Image.asset(
                                  controller.frontBackgroundImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0066FF).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(11),
                                ),
                              ),
                              child: Text(
                                controller.templateNames[index],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? const Color(0xFF0066FF)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Controls for background
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Background Opacity',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            Obx(() => Text(
                              '${controller.backgroundOpacity.value.toStringAsFixed(1)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0066FF),
                              ),
                            )),
                          ],
                        ),
                        Obx(() => Slider(
                          value: controller.backgroundOpacity.value,
                          min: 0,
                          max: 1,
                          onChanged: (value) => controller.setBackgroundOpacity(value),
                          activeColor: const Color(0xFF0066FF),
                          inactiveColor: const Color(0xFFE2E8F0),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => IconButton(
                    onPressed: () => controller.toggleBackground(),
                    icon: Icon(
                      controller.showBackground.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF0066FF),
                    ),
                    tooltip: controller.showBackground.value
                        ? 'Hide Background'
                        : 'Show Background',
                  )),
                ],
              ),

              const SizedBox(height: 12),

              // Reset button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => controller.resetToDefault(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: const Color(0xFFE2E8F0)),
                  ),
                  icon: const Icon(Icons.restore, size: 18),
                  label: Text(
                    'Reset Template to Default',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}