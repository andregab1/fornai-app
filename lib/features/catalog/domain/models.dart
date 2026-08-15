enum Availability { available, comingSoon, unavailable, unknown }

enum ValidationStatus { confirmed, unconfirmed }

class ElementalVariant {
  const ElementalVariant({
    required this.id,
    required this.name,
    required this.type,
    required this.availability,
    required this.validationStatus,
    required this.imageAsset,
  });
  final String id;
  final String name;
  final String type;
  final Availability availability;
  final ValidationStatus validationStatus;
  final String imageAsset;

  factory ElementalVariant.fromJson(Map<String, dynamic> json) =>
      ElementalVariant(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        availability: Availability.values.byName(
          json['availability'] as String,
        ),
        validationStatus: ValidationStatus.values.byName(
          json['validationStatus'] as String,
        ),
        imageAsset: json['imageAsset'] as String,
      );
}

class Elemental {
  const Elemental({
    required this.id,
    required this.name,
    required this.season,
    required this.availability,
    required this.validationStatus,
    required this.variants,
  });
  final String id;
  final String name;
  final String season;
  final Availability availability;
  final ValidationStatus validationStatus;
  final List<ElementalVariant> variants;

  factory Elemental.fromJson(Map<String, dynamic> json) => Elemental(
    id: json['id'] as String,
    name: json['name'] as String,
    season: json['season'] as String,
    availability: Availability.values.byName(json['availability'] as String),
    validationStatus: ValidationStatus.values.byName(
      json['validationStatus'] as String,
    ),
    variants: (json['variants'] as List<dynamic>)
        .map(
          (value) => ElementalVariant.fromJson(value as Map<String, dynamic>),
        )
        .toList(growable: false),
  );
}

class Catalog {
  const Catalog({
    required this.schemaVersion,
    required this.catalogVersion,
    required this.auditedAt,
    required this.elementals,
  });
  final int schemaVersion;
  final String catalogVersion;
  final DateTime auditedAt;
  final List<Elemental> elementals;

  factory Catalog.fromJson(Map<String, dynamic> json) {
    final catalog = Catalog(
      schemaVersion: json['schemaVersion'] as int,
      catalogVersion: json['catalogVersion'] as String,
      auditedAt: DateTime.parse(json['auditedAt'] as String),
      elementals: (json['elementals'] as List<dynamic>)
          .map((value) => Elemental.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
    catalog.validate();
    return catalog;
  }

  void validate() {
    if (schemaVersion != 1) {
      throw const FormatException('Versão de catálogo não suportada.');
    }
    final elementalIds = <String>{};
    final variantIds = <String>{};
    for (final elemental in elementals) {
      if (!elementalIds.add(elemental.id)) {
        throw FormatException('ID de Elemental duplicado: ${elemental.id}');
      }
      if (elemental.variants.isEmpty) {
        throw FormatException('Elemental sem variantes: ${elemental.id}');
      }
      for (final variant in elemental.variants) {
        if (!variant.id.startsWith('${elemental.id}.')) {
          throw FormatException(
            'Variante associada ao Elemental incorreto: ${variant.id}',
          );
        }
        if (!variantIds.add(variant.id)) {
          throw FormatException('ID de variante duplicado: ${variant.id}');
        }
      }
    }
  }

  Set<String> get variantIds => {
    for (final elemental in elementals)
      for (final variant in elemental.variants) variant.id,
  };
}

class ProgressEntry {
  const ProgressEntry({required this.collected, this.collectedAt});
  final bool collected;
  final DateTime? collectedAt;
  Map<String, dynamic> toJson() => {
    'collected': collected,
    if (collectedAt != null)
      'collectedAt': collectedAt!.toUtc().toIso8601String(),
  };
  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
    collected: json['collected'] as bool,
    collectedAt: json['collectedAt'] == null
        ? null
        : DateTime.parse(json['collectedAt'] as String),
  );
}
