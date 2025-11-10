import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midia_select/models/item_midia.dart';
import 'package:midia_select/modules/capture_photo/capture_photo_page.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:path/path.dart';

class UtilsMidiaSelect {
  /// Retorna um objeto ItemMidia de imagem
  static ItemMidia? getItemMidiaImage({
    String? path,
    String? url,
    dynamic obj,
    int? typeImage,
  }) {
    ItemMidia? itemMidia = getItemMidia(
      path: path,
      url: url,
      obj: obj,
    );
    itemMidia?.tipoMidia = TipoMidiaEnum.IMAGEM;
    itemMidia?.typeImage = typeImage;
    return itemMidia;
  }

  /// Retorna um objeto ItemMidia de vídeo
  static ItemMidia? getItemMidiaVideo({
    String? path,
    String? url,
    dynamic obj,
  }) {
    ItemMidia? itemMidia = getItemMidia(
      path: path,
      url: url,
      obj: obj,
    );
    itemMidia?.tipoMidia = TipoMidiaEnum.VIDEO;
    return itemMidia;
  }

  /// Retorna um objeto ItemMidia de áudio
  static ItemMidia? getItemMidiaAudio({
    String? path,
    String? url,
    dynamic obj,
  }) {
    ItemMidia? itemMidia = getItemMidia(
      path: path,
      url: url,
      obj: obj,
    );
    itemMidia?.tipoMidia = TipoMidiaEnum.AUDIO;
    return itemMidia;
  }

  /// Retorna um objeto ItemMidia de arquivo (PDF, DOC, XLS, etc)
  static ItemMidia? getItemMidiaArquivo({
    String? path,
    String? url,
    dynamic obj,
  }) {
    ItemMidia? itemMidia = getItemMidia(
      path: path,
      url: url,
      obj: obj,
    );
    itemMidia?.tipoMidia = TipoMidiaEnum.ARQUIVO;
    return itemMidia;
  }

  /// Método genérico para construir um ItemMidia
  static ItemMidia? getItemMidia({
    String? path,
    String? url,
    dynamic obj,
    int? id,
  }) {
    if (path != null || url != null) {
      ItemMidia item = ItemMidia();
      item.strings = Map();
      if (path != null) {
        item.strings['file'] = basename(path);
      }
      item.path = path;
      item.url = url;
      item.object = obj;
      item.id = id;
      return item;
    }
    return null;
  }

  /// Exibe opções de seleção de mídia (foto, vídeo, arquivo)
  static exibirOpcoesMidia(
    BuildContext buildContext,
    List<TipoMidiaEnum> tiposMidia,
    final Function(ItemMidia) midiaAdded, {
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
    bool galeryUniqueImage = false,
    List<Orientation> allowedPhotoOrientations = const [
      Orientation.landscape,
      Orientation.portrait
    ],
  }) {
    if (tiposMidia.length == 1) {
      switch (tiposMidia.first) {
        case TipoMidiaEnum.IMAGEM:
          _exibirOpcoesFoto(
            buildContext,
            midiaAdded,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
            imageQuality: imageQuality,
            galeryUniqueImage: galeryUniqueImage,
            allowedPhotoOrientations: allowedPhotoOrientations,
          );
          break;
        case TipoMidiaEnum.VIDEO:
          _exibirOpcoesVideo(buildContext, midiaAdded);
          break;
        case TipoMidiaEnum.AUDIO:
          break;
        case TipoMidiaEnum.ARQUIVO:
          _exibirOpcoesArquivo(buildContext, midiaAdded);
          break;
      }
    } else {
      showModalBottomSheet(
        context: buildContext,
        builder: (context) => BottomSheet(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tiposMidia.contains(TipoMidiaEnum.IMAGEM))
                ListTile(
                  title: const Text('Foto'),
                  leading: const Icon(Icons.camera_alt),
                  onTap: () {
                    Navigator.pop(context);
                    _exibirOpcoesFoto(
                      buildContext,
                      midiaAdded,
                      maxHeight: maxHeight,
                      maxWidth: maxWidth,
                      imageQuality: imageQuality,
                      galeryUniqueImage: galeryUniqueImage,
                      allowedPhotoOrientations: allowedPhotoOrientations,
                    );
                  },
                ),
              if (tiposMidia.contains(TipoMidiaEnum.VIDEO))
                ListTile(
                  title: const Text('Vídeo'),
                  leading: const Icon(Icons.videocam),
                  onTap: () {
                    Navigator.pop(context);
                    _exibirOpcoesVideo(buildContext, midiaAdded);
                  },
                ),
              if (tiposMidia.contains(TipoMidiaEnum.ARQUIVO))
                ListTile(
                  title: const Text('Arquivo PDF'),
                  leading: const Icon(Icons.insert_drive_file),
                  onTap: () {
                    Navigator.pop(context);
                    _exibirOpcoesArquivo(buildContext, midiaAdded);
                  },
                ),
            ],
          ),
          onClosing: () {},
        ),
      );
    }
  }

  /// Seleciona imagem (foto da câmera ou galeria)
  static Future<void> _exibirOpcoesFoto(
    BuildContext context,
    final Function(ItemMidia) midiaAdded, {
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
    bool galeryUniqueImage = false,
    List<Orientation> allowedPhotoOrientations = const [
      Orientation.landscape,
      Orientation.portrait
    ],
  }) async {
    if (!UtilsPlatform.isMobile) {
      try {
        String ex = 'jpg, png, jpeg';
        FilePickerCross filePickerCross =
            await FilePickerCross.importFromStorage(
          type: FileTypeCross.image,
          fileExtension: ex,
        );
        String? path = filePickerCross.path;
        ItemMidia? item = getItemMidiaImage(path: path);
        if (item != null) {
          midiaAdded.call(item);
        }
      } catch (e) {
        print(e);
      }
    } else {
      showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
          title: const Text('Selecione a forma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Câmera'),
                leading: const Icon(Icons.camera),
                onTap: () async {
                  Navigator.pop(alertContext);
                  XFile? image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (image != null) {
                    ItemMidia? item = getItemMidiaImage(path: image.path);
                    if (item != null) midiaAdded.call(item);
                  }
                },
              ),
              ListTile(
                title: const Text('Galeria'),
                leading: const Icon(Icons.image),
                onTap: () async {
                  Navigator.pop(alertContext);
                  XFile? image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (image != null) {
                    ItemMidia? item = getItemMidiaImage(path: image.path);
                    if (item != null) midiaAdded.call(item);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Seleciona vídeo
  static Future<void> _exibirOpcoesVideo(
    BuildContext context,
    final Function(ItemMidia) midiaAdded,
  ) async {
    try {
      FilePickerCross filePickerCross = await FilePickerCross.importFromStorage(
        type: FileTypeCross.custom,
        fileExtension: 'mp4, mov, 3gp',
      );
      String? path = filePickerCross.path;
      ItemMidia? item = getItemMidiaVideo(path: path);
      if (item != null) {
        midiaAdded.call(item);
      }
    } catch (_) {}
  }

  /// Seleciona arquivo (PDF, DOC, XLS etc.)
  static Future<void> _exibirOpcoesArquivo(
    BuildContext context,
    final Function(ItemMidia) midiaAdded,
  ) async {
    try {
      FilePickerCross filePickerCross = await FilePickerCross.importFromStorage(
        type: FileTypeCross.custom,
        fileExtension: 'pdf;doc;docx;xls;xlsx;txt',
      );
      String? path = filePickerCross.path;
      ItemMidia? item = getItemMidiaArquivo(path: path);
      if (item != null) {
        midiaAdded.call(item);
      }
    } catch (e) {
      print('Erro ao selecionar arquivo: $e');
    }
  }
}
