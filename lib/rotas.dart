import 'package:fisiofinance/telas/home.dart';
import 'package:fisiofinance/telas/login.dart';
import 'package:flutter/material.dart';

class Rotas{

  static Route<dynamic> gerarRota(RouteSettings settings){

    final args = settings.arguments;
    switch( settings.name) {
      case "/":
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/login":
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      case "/home":
        return MaterialPageRoute(
            builder: (_) => Home()
        );
    }

    return _errorRota();

  }

  static Route<dynamic> _errorRota(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(title: Text("Tela não encontrada!"),),
        body: Center(
          child: Text("Tela não Encontrada"),
        ),
      );
    });
  }

}