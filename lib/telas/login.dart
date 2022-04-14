import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../Model/objetos/usuario.dart';
import '../uteis/cores.dart';
import 'firebase_options.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);


  @override
   void onCreate() async{
  }
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

   TextEditingController _controllerNome = TextEditingController(text: "");
  TextEditingController _controllerEmail = TextEditingController(text: "");
  TextEditingController _controllerSenha = TextEditingController(text: "");
  bool _cadastroUsuario = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _arquivoImagemSelecionado;

  _selecionarImagem() async {

      FilePickerResult? resultado = await FilePicker.platform.pickFiles(

        type: FileType.image
      );

      setState(() {
        _arquivoImagemSelecionado = resultado?.files.single.bytes;
      });

  }

  _uploadImagem(Usuario usuario)  {
    Uint8List arquivoSelecionado = _arquivoImagemSelecionado!;
    if(arquivoSelecionado != null){
      Reference imagePerfilRef = _storage.ref("imagens/perfil/${usuario.idUsuario}.jpg");
      UploadTask uploadTask = imagePerfilRef.putData(arquivoSelecionado);
    
    uploadTask.whenComplete(()async{
      String urlImage = await uploadTask.snapshot.ref.getDownloadURL();
      usuario.urlImage = urlImage;
      final usuariosRef = _firestore.collection("usuarios");
      usuariosRef.doc(usuario.idUsuario)
      .set( usuario.toMap() )
      .then((value) {
        //tela principal
        Navigator.pushReplacementNamed(
            context,
            "/home");
        


      });
    });
    }
  }



  _validarCampos() async {

  String  nome  = _controllerNome.text;
   String email = _controllerEmail.text;
   String senha = _controllerSenha.text;
 
   if( email.isNotEmpty && email.contains("@") ){
      if(senha.isNotEmpty && senha.length > 6){
        if(_cadastroUsuario){

          if(_arquivoImagemSelecionado != null){
            //Cadastro
            if(nome.isNotEmpty && nome.length >= 3){

              await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: senha
              ).then((auth){

                //Upload da imagem.
                String? idUsuario = auth.user?.uid;
                if(idUsuario != null){
                  Usuario usuario = Usuario(
                      idUsuario,
                      nome,
                      email
                  );
                  _uploadImagem(usuario);
                }
                //print("Usuário Cadastrado: $idUsuario");
              });

            }else{
              print("o campo Nome deve conter ao menos 3 caracteres.");
            }

            print("Selecione uma Imagem");
          }

        }else{

          //Login
          await _auth.signInWithEmailAndPassword(
              email: email
              , password: senha
          ).then((auth){
            Navigator.pushReplacementNamed(
                context,
                "/home");
          });

        }
      }else{
          print("Senha Inválida");
      }

   }else {
     print("Email Inválido");
   }

  }
  @override
  Widget build(BuildContext context) {

    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
       color: Cores.corFundo,
        width: larguraTela,
        height: alturaTela,
        child: Stack(
          children: [

            Positioned(
                child: Container(
                  width: larguraTela,
                  height: alturaTela * 0.3,
                  color: Cores.corCima,
                )
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10)
                      )
                    ),
                    child: Container(
                      padding: EdgeInsets.all(40),
                      width: 500,
                      color: Cores.corLogin,
                      child: Column(
                        children: [

                          Visibility(
                            visible: _cadastroUsuario,
                              child: ClipOval(
                                child: _arquivoImagemSelecionado != null
                                    ? Image.memory(
                                      _arquivoImagemSelecionado!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,

                                )
                                    : Image.asset(
                                  "imagens/perfil.png",
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),),

                          SizedBox(height: 8,),
                          
                         Visibility(
                           visible: _cadastroUsuario,
                             child:  OutlinedButton(
                                 onPressed: _selecionarImagem,
                                 child: Text("Selecionar Foto")
                             ),
                         ),
                          
                          SizedBox(height: 8,),

                          Visibility(
                            visible: _cadastroUsuario,
                              child: TextField(//CAMPO NOME
                                keyboardType: TextInputType.text,
                                controller: _controllerNome,
                                decoration: InputDecoration(
                                    hintText: "Nome",
                                    labelText: "Nome",
                                    suffixIcon: Icon(
                                        Icons.person_outline
                                    )
                                ),
                              ),
                          ),

                          TextField(//CAMPO EMAIL
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: InputDecoration(
                              hintText: "Email",
                              labelText: "Email",
                              suffixIcon: Icon(
                                Icons.mail_outline
                              )
                            ),
                          ),

                          TextField(//CAMPO SENHA
                            keyboardType: TextInputType.text,
                            controller: _controllerSenha,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: "Senha",
                                labelText: "Senha",
                                suffixIcon: Icon(
                                    Icons.lock_outline
                                )
                            ),
                          ),
                          
                          SizedBox(height: 20,),


                          Container(//BOTÃO LOGIN / CADASTRAR
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (){

                                _validarCampos();

                              },
                              style: ElevatedButton.styleFrom(
                                primary: Cores.corCima
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                    _cadastroUsuario ? "Cadastrar" : "Login",
                                  style: TextStyle(
                                    fontSize: 20
                                  )
                                ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Text("Login"),
                              Switch(value: _cadastroUsuario,
                                  onChanged: (bool valor){
                                    setState(() {
                                      _cadastroUsuario = valor;
                                    });
                                  }
                              ),
                              Text("Cadastro"),
                            ],
                          )

                      ],
                      ),

                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
