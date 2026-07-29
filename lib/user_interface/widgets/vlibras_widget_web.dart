// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class VLibrasWidget extends StatefulWidget {
  const VLibrasWidget({super.key});

  static html.IFrameElement? _iframe;
  static String? _pendingText;

  static Future<void> buscarTraducao(String texto) async {
    final t = texto.trim();
    if (t.isEmpty) return;

    _pendingText = texto;

    final frame = _iframe;
    if (frame == null || frame.contentWindow == null) {
      debugPrint("VLibras Web: Iframe ainda não pronto para receber: $texto");
      return;
    }

    frame.contentWindow!.postMessage({
      'type': 'VL_TEXT',
      'text': texto,
    }, '*');
  }

  @override
  State<VLibrasWidget> createState() => _VLibrasWidgetState();
}

class _VLibrasWidgetState extends State<VLibrasWidget> {
  static bool _registered = false;
  final String _viewType = 'vlibras-iframe-view';
  bool _hasInternet = true;
  static const double _buttonScale = 1.5;

  @override
  void initState() {
    super.initState();
    _hasInternet = html.window.navigator.onLine ?? true;

    if (_hasInternet) {
      _initIframe();
    }
  }

  void _initIframe() {
    if (!_registered) {
      _registered = true;

      ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final iframe = html.IFrameElement()
          ..style.border = '0'
          ..style.backgroundColor = 'transparent'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'block'
          ..srcdoc = _vlibrasHtml(_buttonScale)
          ..setAttribute('allow', 'autoplay; microphone; camera')
          ..setAttribute(
            'sandbox',
            'allow-scripts allow-same-origin allow-forms allow-popups allow-presentation',
          );

        VLibrasWidget._iframe = iframe;

        iframe.onLoad.listen((_) async {
          debugPrint("VLibras Web: Iframe carregado (onLoad).");

          final pending = VLibrasWidget._pendingText;
          if (pending != null && pending.trim().isNotEmpty) {
            // ✅ igual ao Mathnew: manda 2x com pequeno delay (sem esperar 1500ms)
            await VLibrasWidget.buscarTraducao(pending);
            await Future<void>.delayed(const Duration(milliseconds: 60));
            await VLibrasWidget.buscarTraducao(pending);
          }
        });

        return iframe;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final pending = VLibrasWidget._pendingText;
        if (pending != null && pending.trim().isNotEmpty) {
          await VLibrasWidget.buscarTraducao(pending);
          await Future<void>.delayed(const Duration(milliseconds: 60));
          await VLibrasWidget.buscarTraducao(pending);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final targetWidth = screenWidth * 0.95;
    final targetHeight = screenHeight * 0.90;

    return SizedBox(
      width: targetWidth,
      height: targetHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomRight,
        child: SizedBox(
          width: 300,
          height: 500,
          child: _hasInternet
              ? HtmlElementView(viewType: _viewType)
              : Container(
                  width: 200,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.grey, size: 30),
                      SizedBox(height: 8),
                      Text(
                        "Sem conexão",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

String _vlibrasHtml(double scale) => '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <base href="https://vlibras.gov.br/app/" />

    <style>
      html, body {
        background: transparent !important;
        margin: 0;
        padding: 0;
        overflow: hidden;
      }

      div[vw-access-button], .vw-access-button {
        transform: scale(${scale}) !important;
        transform-origin: bottom right !important;
        -webkit-transform: scale(${scale}) !important;
        -webkit-transform-origin: bottom right !important;
        margin-right: 15px !important;
        margin-bottom: 15px !important;
      }

      [vw]{
        overflow: visible !important;
      }

      .vpw-guide, .vw-guide, .popover, .popover-content, .vpw-onboarding,
      div[class*="popover"], div[class*="onboarding"] {
        display: none !important;
        visibility: hidden !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }

      /* ✅ importante: precisa ser "selecionável" e não 100% invisível */
      #vlibrasText {
        position: fixed;
        left: -10000px;
        top: 0;
        width: 10px;
        height: 10px;
        overflow: hidden;
        opacity: 0.01;
        user-select: text;
        white-space: pre-wrap;
      }
    </style>
  </head>

  <body>
    <div id="vlibrasText">...</div>

    <div vw class="enabled">
      <div vw-access-button class="active"></div>
      <div vw-plugin-wrapper><div class="vw-plugin-top-wrapper"></div></div>
    </div>

    <script src="https://vlibras.gov.br/app/vlibras-plugin.js"></script>

    <script>
      window.widgetInstance = new window.VLibras.Widget('https://vlibras.gov.br/app');

      // --- estilo do botão (reaplica sempre que o DOM mudar) ---
      (function () {
        const SCALE = ${scale};

        function apply() {
          const btn = document.querySelector('[vw-access-button]') || document.querySelector('.vw-access-button');
          if (!btn) return false;

          btn.style.transform = 'scale(' + SCALE + ')';
          btn.style.transformOrigin = 'bottom right';
          btn.style.webkitTransform = 'scale(' + SCALE + ')';
          btn.style.webkitTransformOrigin = 'bottom right';
          btn.style.marginRight = '15px';
          btn.style.marginBottom = '15px';
          return true;
        }

        window.__applyVLButtonStyle = function() {
          try { return apply(); } catch(e) { return false; }
        };

        const t = setInterval(() => { if (apply()) clearInterval(t); }, 200);
        new MutationObserver(() => apply())
          .observe(document.documentElement, { childList: true, subtree: true, attributes: true });
      })();

      // --- funções base (como no Mathnew) ---
      window.setTutorialText = function(text) {
        const el = document.getElementById('vlibrasText');
        if (!el) return;
        el.textContent = (text || "");
      };

      window.translateTutorialText = function() {
        const el = document.getElementById('vlibrasText');
        if (!el) return;

        try {
          const range = document.createRange();
          range.selectNodeContents(el);

          const sel = window.getSelection();
          sel.removeAllRanges();
          sel.addRange(range);

          // ✅ essencial para o VLibras "notar" a seleção
          document.dispatchEvent(new Event('selectionchange'));
        } catch(e) {
          console.log("VLibras selection error:", e);
        }

        try {
          el.dispatchEvent(new MouseEvent('mouseup', { bubbles: true }));
          el.dispatchEvent(new MouseEvent('click', { bubbles: true }));
        } catch(e) {
          console.log("VLibras event error:", e);
        }
      };

      // --- fila de tentativas (rajada controlada) ---
      (function () {
        window.__vl_timers = [];
        window.__vl_lastText = null;

        function clearTimers() {
          (window.__vl_timers || []).forEach(id => clearTimeout(id));
          window.__vl_timers = [];
        }

        function translateOnce() {
          try {
            window.translateTutorialText && window.translateTutorialText();
          } catch (e) {}
        }

        window.queueTranslate = function(text) {
          if (!text) return;

          if (window.__vl_lastText === text) {
            translateOnce();
            return;
          }

          window.__vl_lastText = text;
          clearTimers();

          try { window.setTutorialText && window.setTutorialText(text); } catch(e) {}

          const delays = [0, 80, 160, 320, 640, 1200, 2000];
          delays.forEach((d) => {
            const id = setTimeout(translateOnce, d);
            window.__vl_timers.push(id);
          });
        };
      })();

      // --- ao abrir o widget, re-traduz o último texto (ajuda muito) ---
      (function () {
        function hookOpenClick() {
          const btn = document.querySelector('.vw-access-button') || document.querySelector('[vw-access-button]');
          if (!btn) return false;

          btn.addEventListener('click', () => {
            const attempts = [200, 600, 1200, 2000, 3000];
            attempts.forEach((ms) => {
              setTimeout(() => {
                try {
                  const text = window.__vl_lastText;
                  if (text && window.queueTranslate) window.queueTranslate(text);
                  else window.translateTutorialText && window.translateTutorialText();
                } catch (e) {}
              }, ms);
            });
          });

          return true;
        }

        const timer = setInterval(() => {
          if (hookOpenClick()) clearInterval(timer);
        }, 300);
      })();

      // --- recebe texto do Flutter via postMessage ---
      window.addEventListener('message', function(e) {
        try {
          const data = e.data;
          if (data && data.type === 'VL_TEXT') {
            window.queueTranslate(data.text);
          }
        } catch(err) {}
      });
    </script>
  </body>
</html>
''';
