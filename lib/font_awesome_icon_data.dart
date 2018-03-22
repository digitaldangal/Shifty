library font_awesome_icon_data;

import 'package:flutter/widgets.dart';

class FontAwesomeIcons {
  static const IconData bell = const _IconDataSolid(0xf0f3);

  static const IconData sign_in = const _IconDataRegular(0xf090);
  static const IconData sign_out = const _IconDataRegular(0xf08b);

  static const IconData user_circle = const _IconDataSolid(0xf2bd);
  static const IconData calendar_alt = const _IconDataSolid(0xf073);
  static const IconData briefcase = const _IconDataSolid(0xf0b1);
  static const IconData cog = const _IconDataSolid(0xf013);
}

class _IconDataBrands extends IconData {
  const _IconDataBrands(int codePoint)
      : super(
          codePoint,
          fontFamily: 'FontAwesomeBrands',
        );
}

class _IconDataSolid extends IconData {
  const _IconDataSolid(int codePoint)
      : super(
          codePoint,
          fontFamily: 'FontAwesomeSolid',
        );
}

class _IconDataRegular extends IconData {
  const _IconDataRegular(int codePoint)
      : super(
          codePoint,
          fontFamily: 'FontAwesomeRegular',
        );
}

class _IconDataLight extends IconData {
  const _IconDataLight(int codePoint)
      : super(
          codePoint,
          fontFamily: 'FontAwesomeLight',
        );
}
