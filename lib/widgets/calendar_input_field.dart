import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class CalendarInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const CalendarInputField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
  });

  @override
  State<CalendarInputField> createState() => _CalendarInputFieldState();
}

class _CalendarInputFieldState extends State<CalendarInputField> {
  DateTime? selectedDate;

  Future<void> _openCustomDatePicker(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(widget.controller.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _CalendarSheet(initialDate: initialDate);
      },
    );

    if (picked != null) {
      final formatted = "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";
      widget.controller.text = formatted;
      if (widget.onChanged != null) widget.onChanged!(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFilled = widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          readOnly: true,
          onTap: () => _openCustomDatePicker(context),
          validator: (val) => val == null || val.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.fieldColor,
            hintText: "dd-mm-yyyy",
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                "assets/icons/calendar.svg",
                height: 16,
                colorFilter: ColorFilter.mode(
                  isFilled ? context.buttonColor : context.buttonColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  const _CalendarSheet({required this.initialDate});

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime tempDate;

  @override
  void initState() {
    super.initState();
    tempDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Date",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: context.buttonColor,
                  ),
            ),
            child: CalendarDatePicker(
              initialDate: tempDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (val) => setState(() => tempDate = val),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, tempDate),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
