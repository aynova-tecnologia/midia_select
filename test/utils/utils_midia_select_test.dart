import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:midia_select/utils/utils_midia_select.dart';

/// Cobre o fix da Área P (fotos de pacote órfãs): o image_picker pode
/// devolver um arquivo que mora só no cache do Android, que some antes do
/// fim do sync. `persistirArquivoMidia` copia esse arquivo pra um diretório
/// estável antes de repassar o path adiante (ver docs/BUG_FOTOS_CACHE.md
/// no timber_track).
void main() {
  late Directory tempOrigem;
  late Directory tempDestino;

  setUp(() {
    tempOrigem = Directory.systemTemp.createTempSync('midia_select_origem_');
    tempDestino = Directory.systemTemp.createTempSync('midia_select_destino_');
  });

  tearDown(() {
    if (tempOrigem.existsSync()) tempOrigem.deleteSync(recursive: true);
    if (tempDestino.existsSync()) tempDestino.deleteSync(recursive: true);
  });

  group('persistirArquivoMidia', () {
    test('copia o arquivo de origem para dentro do diretório de destino',
        () async {
      File original = File('${tempOrigem.path}/scaled_foto.jpg')
        ..writeAsBytesSync([1, 2, 3, 4]);

      String pathPersistente = await UtilsMidiaSelect.persistirArquivoMidia(
        original.path,
        diretorioDestino: tempDestino,
      );

      expect(File(pathPersistente).existsSync(), true,
          reason: 'O arquivo copiado precisa existir no destino');
      expect(File(pathPersistente).readAsBytesSync(), [1, 2, 3, 4],
          reason: 'O conteúdo copiado precisa ser idêntico ao original');
      expect(pathPersistente.startsWith(tempDestino.path), true,
          reason: 'O arquivo persistente precisa estar dentro do destino');
    });

    test('sobrevive à exclusão do arquivo original (simula cache limpo)',
        () async {
      File original = File('${tempOrigem.path}/scaled_foto.jpg')
        ..writeAsBytesSync([9, 9, 9]);

      String pathPersistente = await UtilsMidiaSelect.persistirArquivoMidia(
        original.path,
        diretorioDestino: tempDestino,
      );

      original.deleteSync();

      expect(File(pathPersistente).existsSync(), true,
          reason:
              'Arquivo persistente não pode depender do arquivo de cache original');
    });

    test('usa nomes únicos, mesmo persistindo o mesmo arquivo duas vezes',
        () async {
      File original = File('${tempOrigem.path}/scaled_foto.jpg')
        ..writeAsBytesSync([1]);

      String path1 = await UtilsMidiaSelect.persistirArquivoMidia(
        original.path,
        diretorioDestino: tempDestino,
      );
      String path2 = await UtilsMidiaSelect.persistirArquivoMidia(
        original.path,
        diretorioDestino: tempDestino,
      );

      expect(path1, isNot(equals(path2)),
          reason: 'Duas fotos não podem colidir no mesmo arquivo persistido');
      expect(File(path1).existsSync(), true);
      expect(File(path2).existsSync(), true);
    });

    test('usa a subpasta fotos_pendentes por padrão', () async {
      File original = File('${tempOrigem.path}/foto.jpg')
        ..writeAsBytesSync([1]);

      String pathPersistente = await UtilsMidiaSelect.persistirArquivoMidia(
        original.path,
        diretorioDestino: tempDestino,
      );

      expect(pathPersistente.contains('fotos_pendentes'), true);
    });

    test('respeita subpasta customizada quando informada', () async {
      File original = File('${tempOrigem.path}/foto.jpg')
        ..writeAsBytesSync([1]);

      String pathPersistente = await UtilsMidiaSelect.persistirArquivoMidia(
        original.path,
        diretorioDestino: tempDestino,
        subpasta: 'outra_pasta',
      );

      expect(pathPersistente.contains('outra_pasta'), true);
      expect(pathPersistente.contains('fotos_pendentes'), false);
    });
  });

  group('persistirOuManterOriginal', () {
    test('sem falha, devolve o path persistido e não chama aoFalhar',
        () async {
      File original = File('${tempOrigem.path}/foto.jpg')
        ..writeAsBytesSync([1, 2]);
      bool falhou = false;

      String resultado = await UtilsMidiaSelect.persistirOuManterOriginal(
        original.path,
        obterDiretorioDestino: () async => tempDestino,
        aoFalhar: (_, __) => falhou = true,
      );

      expect(falhou, false);
      expect(resultado, isNot(equals(original.path)));
      expect(File(resultado).existsSync(), true);
    });

    test('falha da cópia: avisa e mantém o path original, sem lançar',
        () async {
      // Origem inexistente faz File.copy lançar, como acontece na prática
      // com disco cheio.
      String origem = '${tempOrigem.path}/nao_existe.jpg';
      Object? erroRecebido;

      String resultado = await UtilsMidiaSelect.persistirOuManterOriginal(
        origem,
        obterDiretorioDestino: () async => tempDestino,
        aoFalhar: (erro, _) => erroRecebido = erro,
      );

      expect(resultado, origem,
          reason: 'A captura não pode ser perdida: devolve o path original');
      expect(erroRecebido, isNotNull);
    });

    test('aoFalhar que lança: ainda devolve o path original, sem lançar',
        () async {
      String origem = '${tempOrigem.path}/nao_existe.jpg';

      String resultado = await UtilsMidiaSelect.persistirOuManterOriginal(
        origem,
        obterDiretorioDestino: () async => tempDestino,
        aoFalhar: (_, __) => throw Exception('falha no aviso'),
      );

      expect(resultado, origem);
    });

    test('falha ao obter o diretório de destino também é tratada', () async {
      File original = File('${tempOrigem.path}/foto.jpg')
        ..writeAsBytesSync([1]);
      Object? erroRecebido;

      String resultado = await UtilsMidiaSelect.persistirOuManterOriginal(
        original.path,
        obterDiretorioDestino: () async => throw Exception('sem diretório'),
        aoFalhar: (erro, _) => erroRecebido = erro,
      );

      expect(resultado, original.path);
      expect(erroRecebido, isNotNull);
    });
  });
}
