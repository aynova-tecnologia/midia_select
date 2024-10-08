import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:midia_select/item_midia/item_midia_widget.dart';
import 'package:midia_select/models/item_midia.dart';
import 'package:midia_select/modules/ver_midia/ver_midia_module.dart';
import 'package:midia_select/utils/utils_midia_select.dart';
import 'package:msk_utils/msk_utils.dart';

import 'seletor_midia_controller.dart';

class SeletorMidiaWidget extends StatelessWidget {
  final SeletorMidiaController controller;
  final List<TipoMidiaEnum> tiposMidia;
  final double? maxWidth;
  final double? maxHeight;
  final Widget? title;
  final Function(ItemMidia)? mediaAdded;
  final Function(int)? mediaExcluded;
  final int imageQuality;
  final List<Widget> Function(int index, BuildContext)? extraImageOptons;
  final Widget Function(int index)? customItemMidia;
  final Widget? customEmptyList;

  const SeletorMidiaWidget(
    this.controller, {
    this.maxWidth = 1200,
    this.maxHeight = 2124,
    this.title,
    this.tiposMidia = const [TipoMidiaEnum.IMAGEM],
    this.mediaAdded,
    this.mediaExcluded,
    this.imageQuality = 85,
    this.extraImageOptons,
    this.customItemMidia,
    this.customEmptyList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: title ??
                const Text(
                  'Adicione arquivos aqui',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
          ),
          Container(
            height: 205,
            child: Observer(builder: (_) {
              if (controller.midia
                  .where((element) => !element.isDeleted)
                  .isEmpty) {
                //caso a lista esteja vazia ou, todos os componentes estejam deletados
                return InkWell(
                  onTap: () {
                    onAdd(context);
                  },
                  child: customEmptyList ??
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                'imagens/add_files.png',
                                width: 100,
                                package: 'msk_widgets',
                              ),
                            ),
                            const Text(
                              "Toque em '+' para adicionar arquivos",
                            ),
                          ],
                        ),
                      ),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.midia.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    return Observer(
                      builder: (_) => !controller.midia[index].isDeleted
                          //Só exibe se não estiver deletado
                          ? Hero(
                              tag: index,
                              child: customItemMidia != null
                                  ? InkWell(
                                      child: customItemMidia!(index),
                                      onTap: () =>
                                          _exibirOpcoesItem(context, index),
                                    )
                                  : ItemMidiaWidget(
                                      controller.midia[index],
                                      () => _exibirOpcoesItem(context, index),
                                    ),
                            )
                          //case esteja, apenas deixa um container vazio
                          : const SizedBox(),
                    );
                  },
                );
              }
            }),
          ),
          Container(
            padding: const EdgeInsets.only(top: 16),
            alignment: Alignment.centerRight,
            child: FloatingActionButton(
              heroTag: 'add_midia',
              child: const Icon(
                Icons.add,
              ),
              onPressed: () {
                onAdd(context);
              },
            ),
          )
        ],
      ),
    );
  }

  void onAdd(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    UtilsMidiaSelect.exibirOpcoesMidia(
      context,
      tiposMidia,
      (ItemMidia itemMidia) {
        controller.midia.add(itemMidia);
        mediaAdded?.call(itemMidia);
      },
      imageQuality: imageQuality,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );
  }

  void _exibirOpcoesItem(
    BuildContext context,
    int pos,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (bottomContext) => BottomSheet(
        onClosing: () {},
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Abrir'),
              leading: const Icon(Icons.fullscreen),
              onTap: () {
                Navigator.pop(bottomContext);
                List<ItemMidia> itens = controller.midia
                    .where((element) => !element.isDeleted)
                    .toList();
                int numDeletadosAteIndice = (controller.midia
                    .sublist(0, pos)
                    .where((element) => element.isDeleted)
                    .toList()
                    .length);
                Navigation.push(
                  context,
                  VerMidiaModule(
                    itens,
                    posicaoInicial: pos - numDeletadosAteIndice,
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Remover'),
              leading: const Icon(Icons.close),
              onTap: () {
                Navigator.pop(bottomContext);
                _showDialogConfirmRemove(context, pos);
              },
            )
          ]..addAll(
              extraImageOptons?.call(pos, bottomContext) ?? [],
            ),
        ),
      ),
    );
  }

  void _showDialogConfirmRemove(
    BuildContext context,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: const Text('Remover a foto?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(alertContext);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.midia[index].isDeleted = true;
              mediaExcluded?.call(index);
              Navigator.pop(alertContext);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
