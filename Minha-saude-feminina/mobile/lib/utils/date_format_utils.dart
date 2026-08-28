/// Utilitários simples de formatação de datas em português, sem
/// depender do pacote `intl` (mantendo o projeto com o mínimo de
/// dependências novas possível).
class DateFormatUtils {
  DateFormatUtils._();

  static const List<String> monthNamesFull = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  static const List<String> monthNamesShort = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  static const List<String> weekdayLettersShort = [
    'D', 'S', 'T', 'Q', 'Q', 'S', 'S',
  ];

  /// dd/MM/yyyy
  static String short(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  /// 5 de Março de 2025
  static String long(DateTime d) {
    return '${d.day} de ${monthNamesFull[d.month - 1]} de ${d.year}';
  }

  /// Março de 2025
  static String monthYear(DateTime d) {
    return '${monthNamesFull[d.month - 1]} de ${d.year}';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
