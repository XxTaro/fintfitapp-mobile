import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  late String title;
  late String actionButton;
  late String toggleButton;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  void setFormAction(bool action) {
    setState(() {
      isLogin = action;

      if (isLogin) {
        title = "Bem-vindo!";
        actionButton = "Login";
        toggleButton = "Ainda não tem uma conta? Cadastre-se agora!";
      } else {
        title = "Crie sua conta";
        actionButton = "Cadastrar";
        toggleButton = "Já tenho uma conta";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.75
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "E-mail",
                        border: OutlineInputBorder()
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira um e-mail";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        border: OutlineInputBorder()
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Por favor, insira a senha";
                        }
                        if (value.length < 6) {
                          return "A senha deve ter no mínimo 6 caracteres";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (isLogin) {
                            login();
                          } else {
                            register();
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: loading
                        ? [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(backgroundColor: Colors.white, valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),)
                            ),
                          )
                        ]
                        : 
                        [
                          const Icon(Icons.check),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              actionButton,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setFormAction(!isLogin), 
                    child: Text(
                      toggleButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  )
                ],
              )
            ),
          ),
        ),
      )
    );
  }

  void login() async {
    setState(() => loading = true);
      try {
        await context.read<AuthService>().login(emailController.text, passwordController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login efetuado com sucesso!"),
          backgroundColor: Colors.green,
        ));
      } on AuthException catch (e) {
        setState(() => loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ));
      }
  }

  void register() async {
    setState(() => loading = true);
    try {
        await context.read<AuthService>().register(emailController.text, passwordController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cadastro efetuado com sucesso!"),
          backgroundColor: Colors.green,
        ));
      } on AuthException catch (e) {
        setState(() => loading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ));
      }
  }
}