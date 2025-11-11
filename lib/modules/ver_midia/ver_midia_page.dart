import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:midia_select/models/item_midia.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; 
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; 

import 'ver_midia_controller.dart';
import 'ver_midia_module.dart';

class VerMidiaPage extends StatefulWidget {
  final String title;
  const VerMidiaPage({Key? key, this.title = ""}) : super(key: key);

  @override
  _VerMidiaPageState createState() => _VerMidiaPageState();
}

class _VerMidiaPageState extends State<VerMidiaPage> {
  final VerMidiaController _controller =
      VerMidiaModule.to.bloc<VerMidiaController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _controller.backgroundColor ?? Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: _controller.backgroundColor ?? Colors.black,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: Icon(
            Icons.arrow_back,
            color: _controller.appBarColor ?? Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return Center(
            child: CarouselSlider.builder(
                options: CarouselOptions(
                    height: height - 100,
                    enlargeCenterPage: true,
                    aspectRatio: 2.0,
                    initialPage: _controller.posicao ?? 0,
                    enableInfiniteScroll: false),
                itemCount: _controller.itens.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int realIndex) {
                  return Center(
                    child: Container(
                        child: Hero(
                      tag: realIndex,
                      child: Column(children: [
                        Expanded(
                            child: _getItemMidia(_controller.itens[realIndex])),
                        if (!_controller
                            .itens[realIndex].fileName.isNullOrBlank)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  _controller.itens[realIndex].fileName!,
                                  style: TextStyle(color: Colors.white), 
                                )),
                          )
                      ]),
                    )),
                  );
                }),
          );
        },
      ),
    );
  }

  Widget _getItemMidia(ItemMidia item) {
    Widget errorWidget = Icon(Icons.image_not_supported_outlined, color: Colors.white);

    switch (item.tipoMidia) {
      case TipoMidiaEnum.IMAGEM:
        if (item.url.isNullOrBlank && item.path.isNullOrBlank) {
          return Text('Falha ao carregar imagem');
        }
        return PinchZoomImage(
          image:
              item.path?.isNullOrBlank == false && File(item.path!).existsSync()
                  ? Image.file(File(item.path!),
                      errorBuilder: (_, obj, stack) => errorWidget)
                  : item.url?.isNullOrEmpty == false
                      ? (UtilsPlatform.isWeb || UtilsPlatform.isWindows)
                          ? Image.network(item.url!,
                              errorBuilder: (_, obj, stack) => errorWidget)
                          : CachedNetworkImage(
                              imageUrl: item.url!,
                              fit: BoxFit.contain,
                              errorWidget: (_, s, d) => errorWidget,
                              placeholder: (_, url) =>
                                  Center(child: CircularProgressIndicator()),
                            )
                      : errorWidget,
        );

      case TipoMidiaEnum.ARQUIVO:
        // Verifica se o path existe e se é um arquivo PDF
        bool isPdf = item.path != null &&
            item.path!.toLowerCase().endsWith('.pdf') &&
            File(item.path!).existsSync();

        if (isPdf) {
          if (UtilsPlatform.isWindows || UtilsPlatform.isWeb) {
            return SfPdfViewer.file(
              File(item.path!),
              onDocumentLoadFailed: (details) {
                print("Falha ao carregar PDF no Windows: ${details.description}");
              },
            );
          }
          
          return PDFView(
            filePath: item.path!,
            enableSwipe: true,
            swipeHorizontal: true, 
            autoSpacing: false,
            pageFling: false,
            onError: (error) {
              print('Erro ao carregar PDF (nativo): $error');
            },
          );
        } else {
          // Se for outro tipo de arquivo que não seja PDF
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text(
                  'Visualização não suportada para este arquivo.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

      case TipoMidiaEnum.VIDEO:
        return Text(
          'Não implementado',
          style: TextStyle(color: Colors.white),
        );
      case TipoMidiaEnum.AUDIO:
        {
          return Text(
            'Não implementado',
            style: TextStyle(color: Colors.white),
          );
        }

      default:
        return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text(
                  'Tipo de mídia desconhecido.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
    }
  }
}