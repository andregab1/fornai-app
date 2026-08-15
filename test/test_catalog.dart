import 'package:fornai_app/features/catalog/domain/models.dart';

Catalog testCatalog() => Catalog(
  schemaVersion: 1,
  catalogVersion: 'test.1',
  auditedAt: DateTime.utc(2026, 8, 15),
  elementals: [
    const Elemental(
      id: 'water',
      name: 'Água',
      season: 'Teste',
      availability: Availability.available,
      validationStatus: ValidationStatus.confirmed,
      variants: [
        ElementalVariant(
          id: 'water.normal',
          name: 'Normal',
          type: 'normal',
          imageAsset: 'assets/images/elementals/water_normal.png',
          availability: Availability.available,
          validationStatus: ValidationStatus.confirmed,
        ),
        ElementalVariant(
          id: 'water.gold',
          name: 'Dourado',
          type: 'gold',
          imageAsset: 'assets/images/elementals/water_normal.png',
          availability: Availability.available,
          validationStatus: ValidationStatus.confirmed,
        ),
      ],
    ),
    const Elemental(
      id: 'future',
      name: 'Futuro',
      season: 'Teste',
      availability: Availability.comingSoon,
      validationStatus: ValidationStatus.unconfirmed,
      variants: [
        ElementalVariant(
          id: 'future.normal',
          name: 'Normal',
          type: 'normal',
          imageAsset: 'assets/images/elementals/water_normal.png',
          availability: Availability.comingSoon,
          validationStatus: ValidationStatus.unconfirmed,
        ),
      ],
    ),
  ],
);
