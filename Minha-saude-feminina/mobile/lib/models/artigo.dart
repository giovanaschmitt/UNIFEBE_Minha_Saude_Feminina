import 'package:flutter/material.dart';

/// Categoria de conteúdo, como vem de GET /api/categorias.
class Categoria {
  final int id;
  final String nome;
  final String emoji;
  final Color? cor;

  const Categoria({required this.id, required this.nome, required this.emoji, this.cor});

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: (json['id'] as num).toInt(),
        nome: json['nome'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '',
        cor: corDeHex(json['cor'] as String?),
      );
}

/// Artigo publicado, como vem de GET /api/artigos (sem [conteudoHtml])
/// ou de GET /api/artigos/{id} (completo).
class Artigo {
  final int id;
  final String titulo;
  final String resumo;
  final String? conteudoHtml;
  final String emoji;
  final String? capaUrl;
  final String autora;
  final int tempoLeitura;
  final bool destaque;
  final String categoria;
  final String? categoriaEmoji;
  final Color? categoriaCor;

  const Artigo({
    required this.id,
    required this.titulo,
    required this.resumo,
    required this.conteudoHtml,
    required this.emoji,
    required this.capaUrl,
    required this.autora,
    required this.tempoLeitura,
    required this.destaque,
    required this.categoria,
    required this.categoriaEmoji,
    required this.categoriaCor,
  });

  factory Artigo.fromJson(Map<String, dynamic> json) => Artigo(
        id: (json['id'] as num).toInt(),
        titulo: json['titulo'] as String? ?? '',
        resumo: (json['resumo'] as String? ?? '').trim(),
        conteudoHtml: json['conteudo_html'] as String?,
        emoji: json['emoji'] as String? ?? '💗',
        capaUrl: json['capa_url'] as String?,
        autora: json['autora'] as String? ?? '',
        tempoLeitura: (json['tempo_leitura'] as num?)?.toInt() ?? 3,
        destaque: json['destaque'] as bool? ?? false,
        categoria: json['categoria'] as String? ?? '',
        categoriaEmoji: json['categoria_emoji'] as String?,
        categoriaCor: corDeHex(json['categoria_cor'] as String?),
      );
}

/// Converte "#RRGGBB" (formato salvo pelo painel) em [Color].
Color? corDeHex(String? hex) {
  if (hex == null) return null;
  final limpo = hex.replaceFirst('#', '');
  if (limpo.length != 6) return null;
  final valor = int.tryParse(limpo, radix: 16);
  return valor == null ? null : Color(0xFF000000 | valor);
}
