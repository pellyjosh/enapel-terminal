import 'package:flutter/material.dart';
import 'package:enapel/utils/app_color.dart';

class FilterPopup extends StatefulWidget {
  final Map<String, List<String>> filterOptions;
  final Map<String, String?> initialSelectedValues;
  final String title;
  final bool enableDateFilter;

  const FilterPopup({
    required this.filterOptions,
    required this.initialSelectedValues,
    required this.title,
    this.enableDateFilter = false,
    Key? key,
  }) : super(key: key);

  @override
  State<FilterPopup> createState() => _FilterPopupState();
}

class _FilterPopupState extends State<FilterPopup> {
  late Map<String, String?> selectedValues;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    selectedValues = Map.from(widget.initialSelectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColor.white, width: 2),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColor.white,
        ),
      ),
      backgroundColor: AppColor.black,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter options
            ...widget.filterOptions.entries.map((entry) {
              final category = entry.key;
              final options = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.white,
                    ),
                  ),
                  ...options.map((option) {
                    return RadioListTile<String>(
                      value: option,
                      groupValue: selectedValues[category],
                      onChanged: (value) {
                        setState(() {
                          selectedValues[category] = value;
                        });
                      },
                      title:
                          Text(option, style: TextStyle(color: AppColor.white)),
                      activeColor: AppColor.white,
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }),

            // Optional Date Range
            if (widget.enableDateFilter) ...[
              Text(
                "Date Range",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => fromDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fromDate != null
                              ? "${fromDate!.toLocal()}".split(' ')[0]
                              : "From",
                          style: TextStyle(color: AppColor.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: toDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => toDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          toDate != null
                              ? "${toDate!.toLocal()}".split(' ')[0]
                              : "To",
                          style: TextStyle(color: AppColor.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              selectedValues =
                  widget.filterOptions.map((key, _) => MapEntry(key, null));
              fromDate = null;
              toDate = null;
            });
          },
          child: const Text('Reset'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              ...selectedValues,
              'fromDate': fromDate?.toIso8601String(),
              'toDate': toDate?.toIso8601String(),
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
