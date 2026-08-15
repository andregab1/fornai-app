# Fornai Checklist

Aplicativo Flutter local e offline para acompanhar uma coleção de Elementais/Sprites e suas variantes.

## Estado atual

- Catálogo auditado e versionado com 25 Elementais candidatos e 117 entradas.
- Cinco Elementais e 33 variantes permanecem sinalizados como não confirmados.
- Progresso persistido imediatamente no Hive CE, separado do catálogo.
- Estado e valores derivados com Riverpod.
- Busca, filtros, progresso geral, cards com subchecks, detalhes e ações em lote.
- Backup JSON por copiar/colar, com validação e importação por mesclagem.
- 117 imagens locais do catálogo foram incorporadas por autorização explícita do proprietário para uso pessoal e não público.

## Dependências de produção

- `flutter_riverpod 3.4.2`: estado derivado, injeção de repositório e testes isolados.
- `hive_ce_flutter 2.3.4`: armazenamento local leve e offline. Foi preferido ao Isar porque o MVP armazena apenas um mapa pequeno de progresso por ID e não precisa de consultas relacionais ou geração de código.

Nenhuma dependência de rede, backend, autenticação, analytics ou imagem remota foi adicionada.

## Executar

```powershell
flutter pub get
flutter run
```

## Validar

```powershell
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

O Windows não suporta compilar ou assinar o aplicativo iOS. Essa validação exige macOS, Xcode e a configuração de assinatura da Apple.

## Catálogo e direitos de imagem

Consulte `data/catalog_review.md`. Os dados ainda exigem revisão humana quando a temporada mudar. As imagens locais vieram do catálogo auditado e foram autorizadas pelo proprietário exclusivamente para uso pessoal. Não redistribua nem publique o aplicativo sem uma nova revisão de direitos.