class VisitPlan {
  final String id;
  final String centre;
  final String village;
  final String crop;
  final double quantity;
  final DateTime date;
  final String officialReference;
  final String notes;
  final Set<String> checklist;
  final DateTime updatedAt;

  const VisitPlan({
    required this.id,
    required this.centre,
    required this.village,
    required this.crop,
    required this.quantity,
    required this.date,
    this.officialReference = '',
    this.notes = '',
    this.checklist = const {},
    required this.updatedAt,
  });

  void validate() {
    if (id.isEmpty || centre.trim().isEmpty || centre.length > 120) {
      throw const FormatException('Enter a centre name, up to 120 characters.');
    }
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) {
      throw const FormatException(
        'Enter a quantity between 0 and 10,000 quintals.',
      );
    }
    if (village.length > 100 ||
        notes.length > 500 ||
        officialReference.length > 80 ||
        crop.length > 80) {
      throw const FormatException('The saved plan contains too much text.');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'centre': centre,
    'village': village,
    'crop': crop,
    'quantity': quantity,
    'date': date.toIso8601String(),
    'officialReference': officialReference,
    'notes': notes,
    'checklist': checklist.toList(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory VisitPlan.fromJson(Map<String, dynamic> value) {
    final plan = VisitPlan(
      id: value['id'] as String,
      centre: value['centre'] as String,
      village: value['village'] as String,
      crop: value['crop'] as String,
      quantity: (value['quantity'] as num).toDouble(),
      date: DateTime.parse(value['date'] as String),
      officialReference: value['officialReference'] as String? ?? '',
      notes: value['notes'] as String? ?? '',
      checklist: Set.unmodifiable((value['checklist'] as List).cast<String>()),
      updatedAt: DateTime.parse(value['updatedAt'] as String),
    );
    plan.validate();
    return plan;
  }
}
