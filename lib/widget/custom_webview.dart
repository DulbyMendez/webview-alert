import 'package:flutter/material.dart';
import 'package:test_web/widget/custom_alert.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;
  final List<String> _urlHistory = [];

  @override
  void initState() {
    super.initState();
    final params = WebKitWebViewControllerCreationParams();
    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Actualizar progreso de carga
          },
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              isLoading = true;
              // Agregar la URL al historial si es diferente a la última
              if (_urlHistory.isEmpty || _urlHistory.last != url) {
                _urlHistory.add(url);
              }
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://alertjs-web.vercel.app/'));

    //configuracion del dialogo js
    if (controller.platform is WebKitWebViewController) {
      final wk = controller.platform as WebKitWebViewController;

      // Alert dialog
      wk.setOnJavaScriptAlertDialog((request) async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => CustomJavaScriptDialog(
            title: 'Alerta',
            message: request.message,
            type: 'alert',
          ),
        );
      });

      // Confirm dialog
      wk.setOnJavaScriptConfirmDialog((request) async {
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => CustomJavaScriptDialog(
            title: 'Confirmación',
            message: request.message,
            type: 'confirm',
            confirmText: 'Aceptar',
          ),
        );
        return confirmed ?? false;
      });

      // Prompt dialog
      wk.setOnJavaScriptTextInputDialog((request) async {
        final result = await showDialog<String?>(
          context: context,
          barrierDismissible: false,
          useSafeArea: false,
          builder: (BuildContext dialogContext) => CustomJavaScriptDialog(
            title: 'Ingrese el valor',
            message: request.message,
            type: 'prompt',
            confirmText: 'Aceptar',
            cancelText: 'Cancelar',
            showCancelButton: true,
            defaultValue: request.defaultText,
            onConfirm: (value) {
              Navigator.of(dialogContext).pop(value);
            },
            onCancel: () {
              Navigator.of(dialogContext).pop(null);
            },
          ),
        );
        return result ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Visor Web'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_urlHistory.length > 1) {
                // Eliminar la URL actual
                _urlHistory.removeLast();
                final previousUrl = _urlHistory.last;
                await controller.loadRequest(Uri.parse(previousUrl));
              } else {
                // Si no hay historial, no hacer nada o mostrar un mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No hay página anterior.')),
                );
              }
            },
            tooltip: 'Atrás',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
