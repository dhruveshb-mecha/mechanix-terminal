import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanix_terminal/core/utils/constants.dart';
import 'package:mechanix_terminal/features/data/settings.dart';
import 'package:mechanix_terminal/features/screen/terminal_tabs_screen.dart';
import 'package:mechanix_terminal/features/widgets/terminal_painter.dart';
import 'package:mechanix_terminal/features/widgets/terminal_view.dart';
import 'package:mechanix_terminal/src/rust/frb_generated.dart';
import 'package:mechanix_terminal/src/rust/terminal.dart';

class MockRustLibApi implements RustLibApi {
  final StreamController<int> streamController = StreamController<int>.broadcast();
  TerminalFrame? currentFrame;
  final Map<int, TerminalFrame> frames = {};
  int _nextId = 1;

  @override
  int crateApiSimpleAddTerminal({required int rows, required int cols, String? cwd}) {
    final id = _nextId++;
    if (currentFrame != null) {
      frames[id] = currentFrame!;
    }
    return id;
  }

  @override
  Stream<int> crateApiSimpleCreateTerminalStream() => streamController.stream;

  @override
  String? crateApiSimpleGetTerminalCwd({required int id}) => '/home/test';

  @override
  TerminalFrame? crateApiSimpleGetTerminalFrame({required int id}) => frames[id] ?? currentFrame;

  @override
  Future<void> crateApiSimpleInitApp() async {}

  @override
  bool crateApiSimpleIsTerminalClosed({required int id}) =>
      frames[id]?.isClosed ?? currentFrame?.isClosed ?? false;

  @override
  void crateApiSimplePasteTerminal({required int id, required String input}) {}

  @override
  void crateApiSimpleRemoveTerminal({required int id}) {}

  @override
  void crateApiSimpleResizeTerminal({required int id, required int rows, required int cols}) {}

  @override
  void crateApiSimpleScrollTerminal({required int id, required int lines}) {}

  bool isAppCursorValue = false;
  bool isAltScreenValue = false;
  final List<({int id, String input})> sentInputs = [];
  final List<({int id, String normalSeq, String appSeq})> sentKeys = [];

  void clearRecords() {
    sentInputs.clear();
    sentKeys.clear();
  }

  @override
  bool crateApiSimpleIsTerminalAppCursor({required int id}) => isAppCursorValue;

  @override
  bool crateApiSimpleIsTerminalAltScreen({required int id}) => isAltScreenValue;

  @override
  void crateApiSimpleSendInput({required int id, required String input}) {
    sentInputs.add((id: id, input: input));
  }

  @override
  void crateApiSimpleSendKey({required int id, required String normalSeq, required String appSeq}) {
    sentKeys.add((id: id, normalSeq: normalSeq, appSeq: appSeq));
  }

  @override
  void crateApiSimpleSetActiveTerminal({required int id}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockApi = MockRustLibApi();

  setUpAll(() {
    RustLib.initMock(api: mockApi);
  });

  group('Terminal Rendering Tests', () {
    test('TerminalFrame contains pre-split lines, tagged ANSI colors, and flags', () {
      final frame = TerminalFrame(
        rows: 4,
        cols: 6,
        lines: [
          'Hello!',
          'World~',
          '┌────┐',
          '🚀 汉字',
        ],
        fgColors: Uint32List.fromList([
          0x01000001, 0x01000002, 0x01000003, 0x01000004, 0x01000005, 0x01000006,
          0, 0, 0, 0, 0, 0,
          0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
          0, 0, 0, 0, 0, 0,
        ]),
        bgColors: Uint32List.fromList([
          0, 0, 0, 0, 0, 0,
          0x01000000, 0x01000000, 0xFF585B70, 0xFF585B70, 0, 0,
          0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0,
        ]),
        flags: Uint16List.fromList([
          1, 2, 4, 8, 16, 32, // Bold, Italic, Underline, Dim, Inverse, Strikeout
          0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0,
          256, 512, 0, 256, 512, 0, // Wide char and wide char spacer
        ]),
        cursorX: 2,
        cursorY: 0,
        isClosed: false,
      );

      expect(frame.rows, 4);
      expect(frame.cols, 6);
      expect(frame.lines.length, 4);
      expect(frame.lines[0], 'Hello!');
      expect(frame.lines[2], '┌────┐');
      expect(frame.lines[3], '🚀 汉字');
      expect(frame.fgColors[0], 0x01000001); // Tagged ANSI Red
      expect(frame.bgColors[8], 0xFF585B70); // TrueColor
      expect(frame.flags[0], 1); // Bold
      expect(frame.flags[2], 4); // Underline
      expect(frame.flags[4], 16); // Inverse
      expect(frame.flags[19], 512); // Wide char spacer
      expect(frame.isClosed, isFalse);
    });

    testWidgets('TerminalPainter paints styled ANSI runs with custom palette', (
      WidgetTester tester,
    ) async {
      final frame = TerminalFrame(
        rows: 3,
        cols: 5,
        lines: ['RedFg', 'BgClr', 'Under'],
        fgColors: Uint32List.fromList([
          0x01000001, 0x01000001, 0x01000001, 0x01000001, 0x01000001, // Tagged Red
          0, 0, 0, 0, 0,
          0x01000006, 0x01000006, 0x01000006, 0x01000006, 0x01000006, // Tagged Cyan
        ]),
        bgColors: Uint32List.fromList([
          0, 0, 0, 0, 0,
          0x01000004, 0x01000004, 0x01000004, 0, 0, // Tagged Blue
          0, 0, 0, 0, 0,
        ]),
        flags: Uint16List.fromList([
          1, 1, 1, 1, 1, // bold
          0, 0, 0, 0, 0,
          4, 4, 4, 4, 4, // underline
        ]),
        cursorX: 0,
        cursorY: 0,
        isClosed: false,
      );

      final customPalette = Uint32List.fromList([
        0x1E1E2E, // 0: Black
        0xF38BA8, // 1: Red (Catppuccin Pinkish Red)
        0xA6E3A1, // 2: Green
        0xF9E2AF, // 3: Yellow
        0x89B4FA, // 4: Blue
        0xF5C2E7, // 5: Magenta
        0x94E2D5, // 6: Cyan
        0xBAC2DE, // 7: White
        0x585B70, // 8: Bright Black
        0xF38BA8, // 9: Bright Red
        0xA6E3A1, // 10: Bright Green
        0xF9E2AF, // 11: Bright Yellow
        0x89B4FA, // 12: Bright Blue
        0xF5C2E7, // 13: Bright Magenta
        0x94E2D5, // 14: Bright Cyan
        0xA6ADC8, // 15: Bright White
      ]);

      final painter = TerminalPainter(
        frame,
        14.0,
        8.4,
        16.8,
        Colors.white,
        const Color(0xFF1E1E2E),
        Colors.pink,
        'monospace',
        1,
        colorPalette: customPalette,
        selectionStart: (col: 0, row: 0),
        selectionEnd: (col: 3, row: 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 100),
              painter: painter,
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is TerminalPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('TerminalPainter repaints when font, metrics, or colors change', (
      WidgetTester tester,
    ) async {
      final frame = TerminalFrame(
        rows: 1,
        cols: 1,
        lines: ['A'],
        fgColors: Uint32List.fromList([0]),
        bgColors: Uint32List.fromList([0]),
        flags: Uint16List.fromList([0]),
        cursorX: 0,
        cursorY: 0,
        isClosed: false,
      );

      final painter1 = TerminalPainter(
        frame,
        14.0,
        8.0,
        16.0,
        Colors.white,
        Colors.black,
        Colors.pink,
        'monospace',
        1,
      );

      final painter2 = TerminalPainter(
        frame,
        16.0,
        9.0,
        18.0,
        Colors.white,
        Colors.black,
        Colors.pink,
        'monospace',
        1,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    testWidgets('TerminalView renders and handles symmetric padding', (
      WidgetTester tester,
    ) async {
      final settings = AppSettings(
        fontSize: 14.0,
        fontFamily: 'monospace',
        colorForeground: '#CDD6F4',
        colorBackground: '#1E1E2E',
      );
      final tabController = TabController(length: 1, vsync: const TestVSync());

      mockApi.currentFrame = TerminalFrame(
        rows: 10,
        cols: 20,
        lines: List.generate(10, (i) => 'Line $i              '),
        fgColors: Uint32List(200),
        bgColors: Uint32List(200),
        flags: Uint16List(200),
        cursorX: 0,
        cursorY: 0,
        isClosed: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 400,
              child: TerminalView(
                terminalId: 1,
                settings: settings,
                tabController: tabController,
                index: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TerminalView), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('TerminalView invokes onClosed when terminalStream emits closed terminal', (
      WidgetTester tester,
    ) async {
      final settings = AppSettings(
        fontSize: 14.0,
        fontFamily: 'monospace',
      );
      final tabController = TabController(length: 1, vsync: const TestVSync());

      mockApi.currentFrame = TerminalFrame(
        rows: 10,
        cols: 20,
        lines: List.generate(10, (i) => 'Line $i              '),
        fgColors: Uint32List(200),
        bgColors: Uint32List(200),
        flags: Uint16List(200),
        cursorX: 0,
        cursorY: 0,
        isClosed: false,
      );

      bool closedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 400,
              child: TerminalView(
                terminalId: 1,
                settings: settings,
                tabController: tabController,
                index: 0,
                terminalStream: mockApi.streamController.stream,
                onClosed: () {
                  closedCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(closedCalled, isFalse);

      // Now simulate terminal process exit
      mockApi.currentFrame = TerminalFrame(
        rows: 10,
        cols: 20,
        lines: List.generate(10, (i) => 'Line $i              '),
        fgColors: Uint32List(200),
        bgColors: Uint32List(200),
        flags: Uint16List(200),
        cursorX: 0,
        cursorY: 0,
        isClosed: true,
      );

      mockApi.streamController.add(1);
      await tester.pump();

      expect(closedCalled, isTrue);
    });

    testWidgets('TerminalTabs removes tab when terminal process terminates', (
      WidgetTester tester,
    ) async {
      final settings = AppSettings(
        fontSize: 14.0,
        fontFamily: 'monospace',
      );

      mockApi.currentFrame = TerminalFrame(
        rows: 10,
        cols: 20,
        lines: List.generate(10, (i) => 'Line $i              '),
        fgColors: Uint32List(200),
        bgColors: Uint32List(200),
        flags: Uint16List(200),
        cursorX: 0,
        cursorY: 0,
        isClosed: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TerminalTabs(
            settings: settings,
            onSettingsChanged: (_) {},
            terminalStream: mockApi.streamController.stream,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tab 1'), findsOneWidget);

      // Add a second tab
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);

      // Now close Tab 2 via shell exit simulation
      mockApi.frames[2] = TerminalFrame(
        rows: 10,
        cols: 20,
        lines: List.generate(10, (i) => 'Line $i              '),
        fgColors: Uint32List(200),
        bgColors: Uint32List(200),
        flags: Uint16List(200),
        cursorX: 0,
        cursorY: 0,
        isClosed: true,
      );

      mockApi.streamController.add(2);
      await tester.pumpAndSettle();

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsNothing);
    });

    testWidgets('Inactive TerminalView does not update frame until tab becomes active', (
      WidgetTester tester,
    ) async {
      final settings = AppSettings(
        fontSize: 14.0,
        fontFamily: 'monospace',
      );
      final tabController = TabController(length: 2, vsync: const TestVSync(), initialIndex: 0);

      final initialFrame = TerminalFrame(
        rows: 10,
        cols: 20,
        lines: List.generate(10, (i) => 'Initial $i           '),
        fgColors: Uint32List(200),
        bgColors: Uint32List(200),
        flags: Uint16List(200),
        cursorX: 0,
        cursorY: 0,
        isClosed: false,
      );

      final updatedFrame = TerminalFrame(
        rows: 10,
        cols: 20,
        lines: List.generate(10, (i) => 'Updated $i           '),
        fgColors: Uint32List(200),
        bgColors: Uint32List(200),
        flags: Uint16List(200),
        cursorX: 0,
        cursorY: 0,
        isClosed: false,
      );

      mockApi.frames[2] = initialFrame;

      // Mount Tab 2 with index = 1 (inactive, tabController.index == 0)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminalId: 2,
              settings: settings,
              tabController: tabController,
              index: 1,
              terminalStream: mockApi.streamController.stream,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Update mock frame in backend
      mockApi.frames[2] = updatedFrame;

      // Stream notification for terminalId 2 while tab is inactive
      mockApi.streamController.add(2);
      await tester.pump();

      // State is NOT updated while inactive
      expect(find.byWidgetPredicate((widget) {
        if (widget is CustomPaint && widget.painter is TerminalPainter) {
          final painter = widget.painter as TerminalPainter;
          return painter.frame.lines.first.startsWith('Initial');
        }
        return false;
      }), findsOneWidget);

      // Now switch tab to active
      tabController.index = 1;
      await tester.pump();

      // Frame catches up immediately on active switch
      expect(find.byWidgetPredicate((widget) {
        if (widget is CustomPaint && widget.painter is TerminalPainter) {
          final painter = widget.painter as TerminalPainter;
          return painter.frame.lines.first.startsWith('Updated');
        }
        return false;
      }), findsOneWidget);
    });
  });

  group('Terminal Keyboard Input Resolution Tests', () {
    test('Unmodified cursor and home/end keys resolve to TerminalAppCursorInput with normal and app sequences', () {
      final up = resolveTerminalInput(const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowUp,
        logicalKey: LogicalKeyboardKey.arrowUp,
        timeStamp: Duration.zero,
      ));
      expect(up, isA<TerminalAppCursorInput>());
      final upResult = up as TerminalAppCursorInput;
      expect(upResult.normalSeq, '\x1b[A');
      expect(upResult.appSeq, '\x1bOA');

      final down = resolveTerminalInput(const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowDown,
        logicalKey: LogicalKeyboardKey.arrowDown,
        timeStamp: Duration.zero,
      )) as TerminalAppCursorInput;
      expect(down.normalSeq, '\x1b[B');
      expect(down.appSeq, '\x1bOB');

      final right = resolveTerminalInput(const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowRight,
        logicalKey: LogicalKeyboardKey.arrowRight,
        timeStamp: Duration.zero,
      )) as TerminalAppCursorInput;
      expect(right.normalSeq, '\x1b[C');
      expect(right.appSeq, '\x1bOC');

      final left = resolveTerminalInput(const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.arrowLeft,
        logicalKey: LogicalKeyboardKey.arrowLeft,
        timeStamp: Duration.zero,
      )) as TerminalAppCursorInput;
      expect(left.normalSeq, '\x1b[D');
      expect(left.appSeq, '\x1bOD');

      final home = resolveTerminalInput(const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.home,
        logicalKey: LogicalKeyboardKey.home,
        timeStamp: Duration.zero,
      )) as TerminalAppCursorInput;
      expect(home.normalSeq, '\x1b[H');
      expect(home.appSeq, '\x1bOH');

      final end = resolveTerminalInput(const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.end,
        logicalKey: LogicalKeyboardKey.end,
        timeStamp: Duration.zero,
      )) as TerminalAppCursorInput;
      expect(end.normalSeq, '\x1b[F');
      expect(end.appSeq, '\x1bOF');
    });

    test('Modified arrow keys resolve to standard xterm modifier sequences', () {
      // Test Shift+ArrowUp (mod = 2)
      final shiftUp = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        ),
        isShift: true,
      );
      expect(shiftUp, isA<TerminalNormalInput>());
      expect((shiftUp as TerminalNormalInput).text, '\x1b[1;2A');

      // Test Shift+Tab (BackTab)
      final shiftTab = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.tab,
          logicalKey: LogicalKeyboardKey.tab,
          timeStamp: Duration.zero,
        ),
        isShift: true,
      );
      expect((shiftTab as TerminalNormalInput).text, '\x1b[Z');
    });

    test('Critical Ctrl shortcuts for nano, vim, htop, less resolve correctly', () {
      // Ctrl+O (Nano Save)
      final ctrlO = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyO,
          logicalKey: LogicalKeyboardKey.keyO,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlO as TerminalNormalInput).text, '\x0f');

      // Ctrl+X (Nano Exit)
      final ctrlX = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyX,
          logicalKey: LogicalKeyboardKey.keyX,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlX as TerminalNormalInput).text, '\x18');

      // Ctrl+V (Vim Visual Block)
      final ctrlV = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyV,
          logicalKey: LogicalKeyboardKey.keyV,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlV as TerminalNormalInput).text, '\x16');

      // Ctrl+[ (Vim Escape)
      final ctrlEsc = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.bracketLeft,
          logicalKey: LogicalKeyboardKey.bracketLeft,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlEsc as TerminalNormalInput).text, '\x1b');

      // Ctrl+C (SIGINT)
      final ctrlC = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyC,
          logicalKey: LogicalKeyboardKey.keyC,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlC as TerminalNormalInput).text, '\x03');

      // Ctrl+D (EOF)
      final ctrlD = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyD,
          logicalKey: LogicalKeyboardKey.keyD,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlD as TerminalNormalInput).text, '\x04');

      // Ctrl+Z (SIGTSTP)
      final ctrlZ = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyZ,
          logicalKey: LogicalKeyboardKey.keyZ,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlZ as TerminalNormalInput).text, '\x1a');

      // Ctrl+L (Clear screen / redraw)
      final ctrlL = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyL,
          logicalKey: LogicalKeyboardKey.keyL,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlL as TerminalNormalInput).text, '\x0c');

      // Ctrl+ArrowUp (mod = 5)
      final ctrlUp = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        ),
        isCtrl: true,
      );
      expect((ctrlUp as TerminalNormalInput).text, '\x1b[1;5A');
    });

    test('Standard function keys and navigation keys resolve correctly', () {
      // F1..F4
      expect(
        (resolveTerminalInput(const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.f1,
          logicalKey: LogicalKeyboardKey.f1,
          timeStamp: Duration.zero,
        )) as TerminalNormalInput).text,
        '\x1bOP',
      );
      // F10 (htop quit)
      expect(
        (resolveTerminalInput(const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.f10,
          logicalKey: LogicalKeyboardKey.f10,
          timeStamp: Duration.zero,
        )) as TerminalNormalInput).text,
        '\x1b[21~',
      );
      // Enter and Numpad Enter
      expect(
        (resolveTerminalInput(const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
          timeStamp: Duration.zero,
        )) as TerminalNormalInput).text,
        '\r',
      );
      expect(
        (resolveTerminalInput(const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.numpadEnter,
          logicalKey: LogicalKeyboardKey.numpadEnter,
          timeStamp: Duration.zero,
        )) as TerminalNormalInput).text,
        '\r',
      );
      // Backspace
      expect(
        (resolveTerminalInput(const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.backspace,
          logicalKey: LogicalKeyboardKey.backspace,
          timeStamp: Duration.zero,
        )) as TerminalNormalInput).text,
        '\x7f',
      );
    });

    test('Alt combinations prefix escape correctly', () {
      // Alt+X
      final altX = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyX,
          logicalKey: LogicalKeyboardKey.keyX,
          timeStamp: Duration.zero,
        ),
        isAlt: true,
      );
      expect((altX as TerminalNormalInput).text, '\x1bx');

      // Alt+Enter
      final altEnter = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
          timeStamp: Duration.zero,
        ),
        isAlt: true,
      );
      expect((altEnter as TerminalNormalInput).text, '\x1b\r');

      // Alt+Backspace
      final altBk = resolveTerminalInput(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.backspace,
          logicalKey: LogicalKeyboardKey.backspace,
          timeStamp: Duration.zero,
        ),
        isAlt: true,
      );
      expect((altBk as TerminalNormalInput).text, '\x1b\x7f');
    });
  });

  group('TerminalView Key Dispatch Widget Tests', () {
    testWidgets('TerminalView dispatches ArrowUp via sendKey with both normal and app sequences', (tester) async {
      mockApi.clearRecords();
      final tabController = TabController(length: 1, vsync: const TestVSync());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminalId: 1,
              index: 0,
              tabController: tabController,
              settings: AppSettings(fontSize: 14.0, fontFamily: 'monospace'),
              terminalStream: mockApi.streamController.stream,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(mockApi.sentKeys.length, 1);
      expect(mockApi.sentKeys.first.normalSeq, '\x1b[A');
      expect(mockApi.sentKeys.first.appSeq, '\x1bOA');
      expect(mockApi.sentKeys.first.id, 1);
    });

    testWidgets('TerminalView dispatches F10 and Enter via sendInput', (tester) async {
      mockApi.clearRecords();
      final tabController = TabController(length: 1, vsync: const TestVSync());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TerminalView(
              terminalId: 1,
              index: 0,
              tabController: tabController,
              settings: AppSettings(fontSize: 14.0, fontFamily: 'monospace'),
              terminalStream: mockApi.streamController.stream,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.pump();
      expect(mockApi.sentInputs.length, 1);
      expect(mockApi.sentInputs.first.input, '\x1b[21~');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(mockApi.sentInputs.length, 2);
      expect(mockApi.sentInputs.last.input, '\r');
    });
  });
}
