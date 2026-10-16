/// Fiyatı Türkçe biçimde gösterir: 54999.0 -> "₺54.999,00".
///
/// `intl` paketi kullanılmadığı için binlik ayırma elle yapılır.
String formatPrice(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts[0];

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return '₺$buffer,${parts[1]}';
}
