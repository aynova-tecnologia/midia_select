import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midia_select/models/item_midia.dart';
import 'package:midia_select/modules/capture_photo/capture_photo_page.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:path/path.dart';

class UtilsMidiaSelect {
  static ItemMidia? getItemMidiaImage({
    String? path,
    String? url,
    dynamic obj,
    int? typeImage,
  }) {
    ItemMidia? itemMidia = UtilsMidiaSelect.getItemMidia(
      path: path,
      url: url,
      obj: obj,
    );
    itemMidia?.tipoMidia = TipoMidiaEnum.IMAGEM;
    itemMidia?.typeImage = typeImage;
    return itemMidia;
  }

  static ItemMidia? getItemMidiaVideo({
    String? path,
    String? url,
    dynamic obj,
  }) {
    ItemMidia? itemMidia = UtilsMidiaSelect.getItemMidia(
      path: path,
      url: url,
      obj: obj,
    );
    itemMidia?.tipoMidia = TipoMidiaEnum.VIDEO;
    return itemMidia;
  }

  static ItemMidia? getItemMidiaAudio({
    String? path,
    String? url,
    dynamic obj,
  }) {
    ItemMidia? itemMidia = UtilsMidiaSelect.getItemMidia(
      path: path,
      url: url,
      obj: obj,
    );
    itemMidia?.tipoMidia = TipoMidiaEnum.AUDIO;
    return itemMidia;
  }

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
          _exibirOpcoesVideo(
            buildContext,
            midiaAdded,
          );
          break;
        case TipoMidiaEnum.AUDIO:
          break;
      }
    } else {
      showModalBottomSheet(
        context: buildContext,
        builder: (context) => BottomSheet(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              tiposMidia.contains(TipoMidiaEnum.IMAGEM)
                  ? ListTile(
                      title: const Text(
                        'Foto',
                      ),
                      leading: const Icon(
                        Icons.camera,
                      ),
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
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
                    )
                  : const SizedBox(),
              tiposMidia.contains(TipoMidiaEnum.VIDEO)
                  ? ListTile(
                      title: const Text(
                        'Vídeo',
                      ),
                      leading: const Icon(
                        Icons.videocam,
                      ),
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        _exibirOpcoesVideo(
                          buildContext,
                          midiaAdded,
                        );
                      })
                  : const SizedBox(),
            ],
          ),
          onClosing: () {},
        ),
      );
    }
  }

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
        if (UtilsPlatform.isMacos) {
          // Corrige nomes dos arquivos errados

          path = filePickerCross.path!.replaceAll(ex, '');
        }
        // filePickerCross = await UtilsMidiaSelect.compressImage(
        //     filePickerCross, filePickerCross.fileName, imageQuality);
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
          title: const Text(
            'Selecione a forma',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Câmera',
                ),
                leading: const Icon(
                  Icons.camera,
                ),
                onTap: () async {
                  if (Navigator.canPop(alertContext)) {
                    Navigator.pop(alertContext);
                  }
                  if (UtilsPlatform.isAndroid) {
                    var androidInfo = await DeviceInfoPlugin().androidInfo;
                    if (androidInfo.version.sdkInt >= 21) {
                      try {
                        /// Caso o teclado esteja aberto, fecha ele e da um delay antes de abrir a câmera, para evitar problemas com a câmera
                        if (FocusScope.of(context).isFirstFocus) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          await Future.delayed(
                            const Duration(
                              seconds: 1,
                            ),
                          );
                        }
                      } catch (_) {}
                      var res = await Navigation.push(
                        context,
                        CapturePhotoPage(
                          allowedPhotoOrientations: allowedPhotoOrientations,
                        ),
                      );
                      if (res != null) {
                        ItemMidia? item = getItemMidiaImage(
                          path: res,
                        );
                        if (item != null) {
                          midiaAdded.call(item);
                        }
                      }
                      return;
                    }
                  }

                  XFile? image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (image != null) {
                    ItemMidia? item = getItemMidiaImage(
                      path: image.path,
                    );
                    if (item != null) {
                      midiaAdded.call(item);
                    }
                  }
                },
              ),
              ListTile(
                title: const Text(
                  'Galeria',
                ),
                leading: const Icon(
                  Icons.image,
                ),
                onTap: () async {
                  if (Navigator.canPop(alertContext)) {
                    Navigator.pop(alertContext);
                  }
                  if (!galeryUniqueImage) {
                    List<XFile> images = await ImagePicker().pickMultiImage(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    );

                    if (images.isNotEmpty) {
                      for (XFile image in images) {
                        ItemMidia? item = getItemMidiaImage(
                          path: image.path,
                        );
                        if (item != null) {
                          midiaAdded.call(item);
                        }
                      }
                    }
                  } else {
                    XFile? image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                    );
                    if (image != null) {
                      ItemMidia? item = getItemMidiaImage(
                        path: image.path,
                      );
                      if (item != null) {
                        midiaAdded.call(item);
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  static Future<void> _exibirOpcoesVideo(
    BuildContext context,
    final Function(ItemMidia) midiaAdded,
  ) async {
    if (!UtilsPlatform.isMobile) {
      try {
        String ex = 'mp4, mov, 3gp';
        FilePickerCross filePickerCross =
            await FilePickerCross.importFromStorage(
          type: FileTypeCross.image,
          fileExtension: ex,
        );
        String? path = filePickerCross.path;
        if (UtilsPlatform.isMacos) {
          // Corrige nomes dos arquivos errados

          path = filePickerCross.path!.replaceAll(
            ex,
            '',
          );
        }
        ItemMidia? item = getItemMidiaVideo(
          path: path,
        );
        if (item != null) {
          midiaAdded.call(item);
        }
      } catch (_) {}
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Selecione a forma',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Câmera',
                ),
                leading: const Icon(
                  Icons.camera,
                ),
                onTap: () async {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  XFile? video = await ImagePicker().pickVideo(
                    source: ImageSource.camera,
                  );
                  if (video != null) {
                    ItemMidia? item = getItemMidiaVideo(
                      path: video.path,
                    );
                    if (item != null) {
                      midiaAdded.call(item);
                    }
                  }
                },
              ),
              ListTile(
                title: const Text(
                  'Galeria',
                ),
                leading: const Icon(
                  Icons.image,
                ),
                onTap: () async {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  XFile? video = await ImagePicker().pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (video != null) {
                    ItemMidia? item = getItemMidiaVideo(
                      path: video.path,
                    );
                    if (item != null) {
                      midiaAdded.call(item);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
