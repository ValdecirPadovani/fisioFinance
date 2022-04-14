import'package:flutter/material.dart';
class Usuario{

    String idUsuario;
    String nome;
    String email;
    String urlImage;

    Usuario(
        this.idUsuario,
        this.nome,
        this.email,
    {this.urlImage = ""}
        );

Map<String, dynamic > toMap (){

    Map<String, dynamic> map = {
        "idUsuario" : this.idUsuario,
        "nome" : this.nome,
        "email" : this.email,
        "urlImage" : this.urlImage,
    };
    return map;
}

}