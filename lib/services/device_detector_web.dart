// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

double getScreenWidth() => html.window.innerWidth?.toDouble() ?? 1024;
