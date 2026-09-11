import 'dart:typed_data';

import 'package:flutter/services.dart';

class Constants {
  static const String dbPath = '.config/mechanix_apps/terminal/objectbox';
}

class TermTheme {
  final String name;
  final int fg, bg, cursor, selection;
  final Uint32List palette;
  const TermTheme(
    this.name,
    this.fg,
    this.bg,
    this.cursor,
    this.selection,
    this.palette,
  );
}

final fontFamilies = ['JetBrains mono', 'Cantarell'];

final terminalThemes = [
  TermTheme(
    'catppuccin-mocha',
    0xCDD6F4,
    0x1E1E2E,
    0xF5C2E7,
    0x45475A,
    Uint32List.fromList([
      0x45475A,
      0xF38BA8,
      0xA6E3A1,
      0xF9E2AF,
      0x89B4FA,
      0xF5C2E7,
      0x94E2D5,
      0xBAC2DE,
      0x585B70,
      0xF38BA8,
      0xA6E3A1,
      0xF9E2AF,
      0x89B4FA,
      0xF5C2E7,
      0x94E2D5,
      0xA6ADC8,
    ]),
  ),
  TermTheme(
    'catppuccin-latte',
    0x4C4F69,
    0xEFF1F5,
    0xEA76CB,
    0xACB0BE,
    Uint32List.fromList([
      0x5C5F77,
      0xD20F39,
      0x40A02B,
      0xDF8E1D,
      0x1E66F5,
      0xEA76CB,
      0x179294,
      0xACB0BE,
      0x6C6F85,
      0xD20F39,
      0x40A02B,
      0xDF8E1D,
      0x1E66F5,
      0xEA76CB,
      0x179294,
      0xBCC0CC,
    ]),
  ),
  TermTheme(
    'tokyo-night',
    0xC0CAF5,
    0x1A1B26,
    0xFF9E64,
    0x283457,
    Uint32List.fromList([
      0x15161E,
      0xF7768E,
      0x9ECE6A,
      0xE0AF68,
      0x7AA2F7,
      0xBB9AF7,
      0x7DCFFF,
      0xA9B1D6,
      0x414868,
      0xF7768E,
      0x9ECE6A,
      0xE0AF68,
      0x7AA2F7,
      0xBB9AF7,
      0x7DCFFF,
      0xC0CAF5,
    ]),
  ),
  TermTheme(
    'gruvbox-dark',
    0xEBDBB2,
    0x282828,
    0xFE8019,
    0x3C3836,
    Uint32List.fromList([
      0x282828,
      0xCC241D,
      0x98971A,
      0xD79921,
      0x458588,
      0xB16286,
      0x689D6A,
      0xA89984,
      0x928374,
      0xFB4934,
      0xB8BB26,
      0xFABD2F,
      0x83A598,
      0xD3869B,
      0x8EC07C,
      0xEBDBB2,
    ]),
  ),
  TermTheme(
    'dracula',
    0xF8F8F2,
    0x282A36,
    0xFF79C6,
    0x44475A,
    Uint32List.fromList([
      0x21222C,
      0xFF5555,
      0x50FA7B,
      0xF1FA8C,
      0xBD93F9,
      0xFF79C6,
      0x8BE9FD,
      0xF8F8F2,
      0x6272A4,
      0xFF6E6E,
      0x69FF94,
      0xFFFFA5,
      0xD6ACFF,
      0xFF92DF,
      0xA4FFFF,
      0xFFFFFF,
    ]),
  ),
];

final defaultDarkThemePalette = Uint32List.fromList([
  0x45475A,
  0xF38BA8,
  0xA6E3A1,
  0xF9E2AF,
  0x89B4FA,
  0xF5C2E7,
  0x94E2D5,
  0xBAC2DE,
  0x585B70,
  0xF38BA8,
  0xA6E3A1,
  0xF9E2AF,
  0x89B4FA,
  0xF5C2E7,
  0x94E2D5,
  0xA6ADC8,
]);

final defaultLightThemePalette = Uint32List.fromList([
  0x5C5F77,
  0xD20F39,
  0x40A02B,
  0xDF8E1D,
  0x1E66F5,
  0xEA76CB,
  0x179294,
  0xACB0BE,
  0x6C6F85,
  0xD20F39,
  0x40A02B,
  0xDF8E1D,
  0x1E66F5,
  0xEA76CB,
  0x179294,
  0xBCC0CC,
]);

class AppCursorKey {
  final String normalSeq;
  final String appSeq;
  const AppCursorKey(this.normalSeq, this.appSeq);
}

final Map<LogicalKeyboardKey, AppCursorKey> appCursorKeys = {
  LogicalKeyboardKey.arrowUp: const AppCursorKey('\x1b[A', '\x1bOA'),
  LogicalKeyboardKey.arrowDown: const AppCursorKey('\x1b[B', '\x1bOB'),
  LogicalKeyboardKey.arrowRight: const AppCursorKey('\x1b[C', '\x1bOC'),
  LogicalKeyboardKey.arrowLeft: const AppCursorKey('\x1b[D', '\x1bOD'),
  LogicalKeyboardKey.home: const AppCursorKey('\x1b[H', '\x1bOH'),
  LogicalKeyboardKey.end: const AppCursorKey('\x1b[F', '\x1bOF'),
};

sealed class TerminalInputResult {
  const TerminalInputResult();
}

class TerminalNormalInput extends TerminalInputResult {
  final String text;
  const TerminalNormalInput(this.text);
}

class TerminalAppCursorInput extends TerminalInputResult {
  final String normalSeq;
  final String appSeq;
  const TerminalAppCursorInput(this.normalSeq, this.appSeq);
}

final Map<LogicalKeyboardKey, String> ctrlMappings = {
  // All 26 letters A-Z (\x01 - \x1a)
  LogicalKeyboardKey.keyA: '\x01',
  LogicalKeyboardKey.keyB: '\x02',
  LogicalKeyboardKey.keyC: '\x03',
  LogicalKeyboardKey.keyD: '\x04',
  LogicalKeyboardKey.keyE: '\x05',
  LogicalKeyboardKey.keyF: '\x06',
  LogicalKeyboardKey.keyG: '\x07',
  LogicalKeyboardKey.keyH: '\x08',
  LogicalKeyboardKey.keyI: '\x09',
  LogicalKeyboardKey.keyJ: '\x0a',
  LogicalKeyboardKey.keyK: '\x0b',
  LogicalKeyboardKey.keyL: '\x0c',
  LogicalKeyboardKey.keyM: '\x0d',
  LogicalKeyboardKey.keyN: '\x0e',
  LogicalKeyboardKey.keyO: '\x0f',
  LogicalKeyboardKey.keyP: '\x10',
  LogicalKeyboardKey.keyQ: '\x11',
  LogicalKeyboardKey.keyR: '\x12',
  LogicalKeyboardKey.keyS: '\x13',
  LogicalKeyboardKey.keyT: '\x14',
  LogicalKeyboardKey.keyU: '\x15',
  LogicalKeyboardKey.keyV: '\x16',
  LogicalKeyboardKey.keyW: '\x17',
  LogicalKeyboardKey.keyX: '\x18',
  LogicalKeyboardKey.keyY: '\x19',
  LogicalKeyboardKey.keyZ: '\x1a',

  // Control punctuation and symbols
  LogicalKeyboardKey.space: '\x00',
  LogicalKeyboardKey.digit2: '\x00',
  LogicalKeyboardKey.bracketLeft: '\x1b',
  LogicalKeyboardKey.digit3: '\x1b',
  LogicalKeyboardKey.backslash: '\x1c',
  LogicalKeyboardKey.digit4: '\x1c',
  LogicalKeyboardKey.bracketRight: '\x1d',
  LogicalKeyboardKey.digit5: '\x1d',
  LogicalKeyboardKey.digit6: '\x1e',
  LogicalKeyboardKey.slash: '\x1f',
  LogicalKeyboardKey.minus: '\x1f',
  LogicalKeyboardKey.digit7: '\x1f',
  LogicalKeyboardKey.digit8: '\x7f',
  LogicalKeyboardKey.backspace: '\x08',
  LogicalKeyboardKey.tab: '\t',

  // Navigation with Ctrl (modifier 5)
  LogicalKeyboardKey.arrowUp: '\x1b[1;5A',
  LogicalKeyboardKey.arrowDown: '\x1b[1;5B',
  LogicalKeyboardKey.arrowRight: '\x1b[1;5C',
  LogicalKeyboardKey.arrowLeft: '\x1b[1;5D',
  LogicalKeyboardKey.home: '\x1b[1;5H',
  LogicalKeyboardKey.end: '\x1b[1;5F',
  LogicalKeyboardKey.insert: '\x1b[2;5~',
  LogicalKeyboardKey.delete: '\x1b[3;5~',
  LogicalKeyboardKey.pageUp: '\x1b[5;5~',
  LogicalKeyboardKey.pageDown: '\x1b[6;5~',

  // Function keys with Ctrl (modifier 5)
  LogicalKeyboardKey.f1: '\x1b[1;5P',
  LogicalKeyboardKey.f2: '\x1b[1;5Q',
  LogicalKeyboardKey.f3: '\x1b[1;5R',
  LogicalKeyboardKey.f4: '\x1b[1;5S',
  LogicalKeyboardKey.f5: '\x1b[15;5~',
  LogicalKeyboardKey.f6: '\x1b[17;5~',
  LogicalKeyboardKey.f7: '\x1b[18;5~',
  LogicalKeyboardKey.f8: '\x1b[19;5~',
  LogicalKeyboardKey.f9: '\x1b[20;5~',
  LogicalKeyboardKey.f10: '\x1b[21;5~',
  LogicalKeyboardKey.f11: '\x1b[23;5~',
  LogicalKeyboardKey.f12: '\x1b[24;5~',
};

final Map<LogicalKeyboardKey, String> altMappings = {
  // Navigation with Alt (modifier 3)
  LogicalKeyboardKey.arrowUp: '\x1b[1;3A',
  LogicalKeyboardKey.arrowDown: '\x1b[1;3B',
  LogicalKeyboardKey.arrowLeft: '\x1b[1;3D',
  LogicalKeyboardKey.arrowRight: '\x1b[1;3C',
  LogicalKeyboardKey.home: '\x1b[1;3H',
  LogicalKeyboardKey.end: '\x1b[1;3F',
  LogicalKeyboardKey.insert: '\x1b[2;3~',
  LogicalKeyboardKey.delete: '\x1b[3;3~',
  LogicalKeyboardKey.pageUp: '\x1b[5;3~',
  LogicalKeyboardKey.pageDown: '\x1b[6;3~',

  // Special keys with Alt
  LogicalKeyboardKey.enter: '\x1b\r',
  LogicalKeyboardKey.numpadEnter: '\x1b\r',
  LogicalKeyboardKey.backspace: '\x1b\x7f',
  LogicalKeyboardKey.tab: '\x1b\t',
  LogicalKeyboardKey.escape: '\x1b\x1b',
  LogicalKeyboardKey.period: '\x1b.',

  // Function keys with Alt (modifier 3)
  LogicalKeyboardKey.f1: '\x1b[1;3P',
  LogicalKeyboardKey.f2: '\x1b[1;3Q',
  LogicalKeyboardKey.f3: '\x1b[1;3R',
  LogicalKeyboardKey.f4: '\x1b[1;3S',
  LogicalKeyboardKey.f5: '\x1b[15;3~',
  LogicalKeyboardKey.f6: '\x1b[17;3~',
  LogicalKeyboardKey.f7: '\x1b[18;3~',
  LogicalKeyboardKey.f8: '\x1b[19;3~',
  LogicalKeyboardKey.f9: '\x1b[20;3~',
  LogicalKeyboardKey.f10: '\x1b[21;3~',
  LogicalKeyboardKey.f11: '\x1b[23;3~',
  LogicalKeyboardKey.f12: '\x1b[24;3~',
};

final Map<LogicalKeyboardKey, String> shiftMappings = {
  // Navigation with Shift (modifier 2)
  LogicalKeyboardKey.arrowUp: '\x1b[1;2A',
  LogicalKeyboardKey.arrowDown: '\x1b[1;2B',
  LogicalKeyboardKey.arrowLeft: '\x1b[1;2D',
  LogicalKeyboardKey.arrowRight: '\x1b[1;2C',
  LogicalKeyboardKey.home: '\x1b[1;2H',
  LogicalKeyboardKey.end: '\x1b[1;2F',
  LogicalKeyboardKey.insert: '\x1b[2;2~',
  LogicalKeyboardKey.delete: '\x1b[3;2~',
  LogicalKeyboardKey.pageUp: '\x1b[5;2~',
  LogicalKeyboardKey.pageDown: '\x1b[6;2~',
  LogicalKeyboardKey.tab: '\x1b[Z',

  // Function keys with Shift (modifier 2)
  LogicalKeyboardKey.f1: '\x1b[1;2P',
  LogicalKeyboardKey.f2: '\x1b[1;2Q',
  LogicalKeyboardKey.f3: '\x1b[1;2R',
  LogicalKeyboardKey.f4: '\x1b[1;2S',
  LogicalKeyboardKey.f5: '\x1b[15;2~',
  LogicalKeyboardKey.f6: '\x1b[17;2~',
  LogicalKeyboardKey.f7: '\x1b[18;2~',
  LogicalKeyboardKey.f8: '\x1b[19;2~',
  LogicalKeyboardKey.f9: '\x1b[20;2~',
  LogicalKeyboardKey.f10: '\x1b[21;2~',
  LogicalKeyboardKey.f11: '\x1b[23;2~',
  LogicalKeyboardKey.f12: '\x1b[24;2~',
};

final Map<LogicalKeyboardKey, String> defaultMappings = {
  LogicalKeyboardKey.enter: '\r',
  LogicalKeyboardKey.numpadEnter: '\r',
  LogicalKeyboardKey.backspace: '\x7f',
  LogicalKeyboardKey.tab: '\t',
  LogicalKeyboardKey.escape: '\x1b',
  LogicalKeyboardKey.delete: '\x1b[3~',
  LogicalKeyboardKey.home: '\x1b[H',
  LogicalKeyboardKey.end: '\x1b[F',
  LogicalKeyboardKey.pageUp: '\x1b[5~',
  LogicalKeyboardKey.pageDown: '\x1b[6~',
  LogicalKeyboardKey.insert: '\x1b[2~',
  LogicalKeyboardKey.arrowUp: '\x1b[A',
  LogicalKeyboardKey.arrowDown: '\x1b[B',
  LogicalKeyboardKey.arrowRight: '\x1b[C',
  LogicalKeyboardKey.arrowLeft: '\x1b[D',
  LogicalKeyboardKey.f1: '\x1bOP',
  LogicalKeyboardKey.f2: '\x1bOQ',
  LogicalKeyboardKey.f3: '\x1bOR',
  LogicalKeyboardKey.f4: '\x1bOS',
  LogicalKeyboardKey.f5: '\x1b[15~',
  LogicalKeyboardKey.f6: '\x1b[17~',
  LogicalKeyboardKey.f7: '\x1b[18~',
  LogicalKeyboardKey.f8: '\x1b[19~',
  LogicalKeyboardKey.f9: '\x1b[20~',
  LogicalKeyboardKey.f10: '\x1b[21~',
  LogicalKeyboardKey.f11: '\x1b[23~',
  LogicalKeyboardKey.f12: '\x1b[24~',
  LogicalKeyboardKey.numpadAdd: '+',
  LogicalKeyboardKey.numpadSubtract: '-',
  LogicalKeyboardKey.numpadMultiply: '*',
  LogicalKeyboardKey.numpadDivide: '/',
  LogicalKeyboardKey.numpadDecimal: '.',
};

String? _getModifiedSpecialKey(LogicalKeyboardKey key, int mod) {
  // Arrow keys
  if (key == LogicalKeyboardKey.arrowUp) return '\x1b[1;${mod}A';
  if (key == LogicalKeyboardKey.arrowDown) return '\x1b[1;${mod}B';
  if (key == LogicalKeyboardKey.arrowRight) return '\x1b[1;${mod}C';
  if (key == LogicalKeyboardKey.arrowLeft) return '\x1b[1;${mod}D';

  // Home / End
  if (key == LogicalKeyboardKey.home) return '\x1b[1;${mod}H';
  if (key == LogicalKeyboardKey.end) return '\x1b[1;${mod}F';

  // Insert, Delete, PageUp, PageDown
  if (key == LogicalKeyboardKey.insert) return '\x1b[2;$mod~';
  if (key == LogicalKeyboardKey.delete) return '\x1b[3;$mod~';
  if (key == LogicalKeyboardKey.pageUp) return '\x1b[5;$mod~';
  if (key == LogicalKeyboardKey.pageDown) return '\x1b[6;$mod~';

  // Function keys F1-F4
  if (key == LogicalKeyboardKey.f1) return '\x1b[1;${mod}P';
  if (key == LogicalKeyboardKey.f2) return '\x1b[1;${mod}Q';
  if (key == LogicalKeyboardKey.f3) return '\x1b[1;${mod}R';
  if (key == LogicalKeyboardKey.f4) return '\x1b[1;${mod}S';

  // Function keys F5-F12
  if (key == LogicalKeyboardKey.f5) return '\x1b[15;$mod~';
  if (key == LogicalKeyboardKey.f6) return '\x1b[17;$mod~';
  if (key == LogicalKeyboardKey.f7) return '\x1b[18;$mod~';
  if (key == LogicalKeyboardKey.f8) return '\x1b[19;$mod~';
  if (key == LogicalKeyboardKey.f9) return '\x1b[20;$mod~';
  if (key == LogicalKeyboardKey.f10) return '\x1b[21;$mod~';
  if (key == LogicalKeyboardKey.f11) return '\x1b[23;$mod~';
  if (key == LogicalKeyboardKey.f12) return '\x1b[24;$mod~';

  return null;
}

TerminalInputResult? resolveTerminalInput(
  KeyEvent event, {
  bool? isCtrl,
  bool? isAlt,
  bool? isShift,
}) {
  final key = event.logicalKey;
  final ctrl = isCtrl ?? HardwareKeyboard.instance.isControlPressed;
  final alt = isAlt ?? HardwareKeyboard.instance.isAltPressed;
  final shift = isShift ?? HardwareKeyboard.instance.isShiftPressed;

  final int mod = 1 + (shift ? 1 : 0) + (alt ? 2 : 0) + (ctrl ? 4 : 0);

  // 1. Unmodified Application Cursor Key candidates (mod == 1)
  if (mod == 1) {
    final appCursor = appCursorKeys[key];
    if (appCursor != null) {
      return TerminalAppCursorInput(appCursor.normalSeq, appCursor.appSeq);
    }
  }

  // 2. Special navigation & function keys with any modifier (mod >= 2)
  if (mod > 1) {
    final modSeq = _getModifiedSpecialKey(key, mod);
    if (modSeq != null) {
      return TerminalNormalInput(modSeq);
    }
  }

  // 3. Shift+Tab (BackTab)
  if (shift && !ctrl && !alt && key == LogicalKeyboardKey.tab) {
    return const TerminalNormalInput('\x1b[Z');
  }

  // 4. Ctrl shortcuts (Ctrl alone, or Ctrl+Shift when not copy/paste)
  if (ctrl && !alt) {
    // Letters A-Z (\x01 - \x1a)
    if (key.keyId >= LogicalKeyboardKey.keyA.keyId &&
        key.keyId <= LogicalKeyboardKey.keyZ.keyId) {
      final code = key.keyId - LogicalKeyboardKey.keyA.keyId + 1;
      return TerminalNormalInput(String.fromCharCode(code));
    }
    final ctrlVal = ctrlMappings[key];
    if (ctrlVal != null) {
      return TerminalNormalInput(ctrlVal);
    }
  }

  // 5. Alt + Ctrl shortcuts (Ctrl+Alt combinations)
  if (ctrl && alt) {
    if (key.keyId >= LogicalKeyboardKey.keyA.keyId &&
        key.keyId <= LogicalKeyboardKey.keyZ.keyId) {
      final code = key.keyId - LogicalKeyboardKey.keyA.keyId + 1;
      return TerminalNormalInput('\x1b${String.fromCharCode(code)}');
    }
    final ctrlVal = ctrlMappings[key];
    if (ctrlVal != null) {
      return TerminalNormalInput('\x1b$ctrlVal');
    }
  }

  // 6. Alt shortcuts (Alt alone, or Alt+Shift)
  if (alt && !ctrl) {
    // Explicit altMappings (Enter, Backspace, Tab, Escape, etc.)
    final altVal = altMappings[key];
    if (altVal != null) {
      return TerminalNormalInput(altVal);
    }

    // Digits
    if (key == LogicalKeyboardKey.digit0) {
      return const TerminalNormalInput('\x1b0');
    }
    if (key.keyId >= LogicalKeyboardKey.digit1.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      final d = key.keyId - LogicalKeyboardKey.digit1.keyId + 1;
      return TerminalNormalInput('\x1b$d');
    }

    // Letters A-Z
    if (key.keyId >= LogicalKeyboardKey.keyA.keyId &&
        key.keyId <= LogicalKeyboardKey.keyZ.keyId) {
      final base = shift ? 65 : 97;
      final ch = String.fromCharCode(
        base + (key.keyId - LogicalKeyboardKey.keyA.keyId),
      );
      return TerminalNormalInput('\x1b$ch');
    }

    // Other printable characters
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final character = event.character;
      if (character != null && character.isNotEmpty) {
        return TerminalNormalInput('\x1b$character');
      }
    }
    if (key.keyLabel.length == 1) {
      return TerminalNormalInput('\x1b${key.keyLabel}');
    }
  }

  // 7. Shift-specific mappings when not handled above
  if (shift) {
    final shiftVal = shiftMappings[key];
    if (shiftVal != null) {
      return TerminalNormalInput(shiftVal);
    }
  }

  // 8. Default unmodified keys
  final defaultVal = defaultMappings[key];
  if (defaultVal != null) {
    return TerminalNormalInput(defaultVal);
  }

  // 9. Standard printable characters
  if (event is KeyDownEvent || event is KeyRepeatEvent) {
    final character = event.character;
    if (character != null && character.isNotEmpty) {
      return TerminalNormalInput(character);
    }
  }

  return null;
}
