// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seletor_midia_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SeletorMidiaController on _SeletorMidiaBase, Store {
  late final _$tempoGravacaoAtom =
      Atom(name: '_SeletorMidiaBase.tempoGravacao', context: context);

  @override
  int get tempoGravacao {
    _$tempoGravacaoAtom.reportRead();
    return super.tempoGravacao;
  }

  @override
  set tempoGravacao(int value) {
    _$tempoGravacaoAtom.reportWrite(value, super.tempoGravacao, () {
      super.tempoGravacao = value;
    });
  }

  late final _$gravandoAtom =
      Atom(name: '_SeletorMidiaBase.gravando', context: context);

  @override
  bool get gravando {
    _$gravandoAtom.reportRead();
    return super.gravando;
  }

  @override
  set gravando(bool value) {
    _$gravandoAtom.reportWrite(value, super.gravando, () {
      super.gravando = value;
    });
  }

  late final _$midiaAtom =
      Atom(name: '_SeletorMidiaBase.midia', context: context);

  @override
  ObservableList<ItemMidia> get midia {
    _$midiaAtom.reportRead();
    return super.midia;
  }

  @override
  set midia(ObservableList<ItemMidia> value) {
    _$midiaAtom.reportWrite(value, super.midia, () {
      super.midia = value;
    });
  }

  @override
  String toString() {
    return '''
tempoGravacao: ${tempoGravacao},
gravando: ${gravando},
midia: ${midia}
    ''';
  }
}
