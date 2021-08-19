import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:midia_select/models/item_midia.dart';
import 'package:msk_utils/msk_utils.dart';

import 'item_midia_controller.dart';

class ItemMidiaWidget extends StatelessWidget {
  final double height;
  final double width;

  final ItemMidiaController controller = ItemMidiaController();
  final VoidCallback? _onTap;

  ItemMidiaWidget(ItemMidia itemFoto, this._onTap,
      {this.height = 140, this.width = 110}) {
    controller.item = itemFoto;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Container(
          width: width,
          height: height + 40,
          child: Card(
            child: InkWell(
              onTap: _onTap,
              child: Column(
                children: <Widget>[
                  Container(
                    width: width,
                    height: height,
                    child: Stack(children: [
                      Container(
                          width: width,
                          height: height + 40,
                          child: _getMidia()),
                      Container(
                        width: width,
                        height: height,
                        color: controller.item!.deletado == true
                            ? Colors.white70
                            : Colors.transparent,
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          controller.item!.deletado
                              ? 'Removida'
                              : controller.item!.strings!.values.firstOrNull ??
                                  '',
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: controller.item!.deletado
                              ? TextStyle(color: Colors.red)
                              : null,
                        )),
                  )
                ],
              ),
            ),
          ));
    });
  }

  Widget _getMidia() {
    switch (controller.item!.tipoMidia) {
      case TipoMidiaEnum.IMAGEM:
        return _getImagem();
      case TipoMidiaEnum.AUDIO:
        return _getWidgetOutrasMidias(Image.asset(
          'imagens/icone_audio.png',
          width: width - 30,
          height: height - 30,
        ));
      case TipoMidiaEnum.VIDEO:
        return _getWidgetOutrasMidias(Image.asset('imagens/icone_video.png'));
      default:
        return _getWidgetOutrasMidias(Image.asset('imagens/icone_video.png'));
    }
  }

  Widget _getWidgetOutrasMidias(Widget icone) {
    return Container(
      width: width,
      height: height,
      child: Center(
        child: icone,
      ),
    );
  }

  Widget _getImagem() {
    if (controller.item!.url?.isNotEmpty == true) {
      if (UtilsPlatform.isWindows || UtilsPlatform.isWeb) {
        return Image.network(
          controller.item!.url!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      } else
        return CachedNetworkImage(
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorWidget: (_, _a, _b) {
            return Text('Falha ao carregar imagem');
          },
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
          imageUrl: controller.item!.url!,
        );
    } else {
      if (controller.item?.path != null) {
        return Image.file(File(controller.item!.path!),
            fit: BoxFit.cover, width: width, height: height);
      }
    }
    return Icon(Icons.image);
  }
}
