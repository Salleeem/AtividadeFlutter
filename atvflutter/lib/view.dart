import 'package:flutter/material.dart';
import 'package:atvflutter/controll.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao Aplicativo!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text('Cadastro'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  _login(context, username, password);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context, String username, String password) async {
    final controller = DatabaseController();
    final user = await controller.loginUser(username, password);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(username: user.username),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário ou senha incorretos.'),
        ),
      );
    }
  }
}

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  _register(context, username, password);
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register(BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome de usuário e senha são obrigatórios.'),
        ),
      );
      return;
    }

    try {
      final controller = DatabaseController();
      if (await controller.registerUser(username, password)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Usuário registrado com sucesso.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro durante o registro: '),
        ));
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro durante o registro: $error'),
        ),
      );
    }
  }
}

class WelcomePage extends StatelessWidget {
  final String username;

  WelcomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo, $username!, o que deseja fazer?'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaginaTreinos(username: username)),
                );
              },
              child: const Text('Treinos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaginaTreinos extends StatefulWidget {
  final String username;

  const PaginaTreinos({Key? key, required this.username}) : super(key: key);

  @override
  _PaginaTreinosState createState() => _PaginaTreinosState(username: username);
}

class _PaginaTreinosState extends State<PaginaTreinos> {
  final String username;
  late SharedPreferences _prefs;
  late List<bool> _exerciciosFeitosDia1;
  late List<bool> _exerciciosFeitosDia2;
  late List<bool> _exerciciosFeitosDia3;
  late List<String> _exerciciosDia1;
  late List<String> _exerciciosDia2;
  late List<String> _exerciciosDia3;

  _PaginaTreinosState({required this.username});

  @override
  void initState() {
    super.initState();
    _initializeExercicios();
    _loadPreferences();
  }

  void _initializeExercicios() {
    // Definir exercícios para cada dia
    _exerciciosDia1 = [
      '1- Crucifixo no Banco',
      '2- Supino Inclinado com Halter ',
      '3- Crossover com Pegada Alta '
    ];
    _exerciciosDia2 = [
      '1- Levantamento Terra',
      '2- Leg Press',
      '3- Cadeira Extensora'
    ];
    _exerciciosDia3 = [
      '1- Rosca Martelo ',
      '2- Remada Curvada',
      '3- Puxada Frontal'
    ];

    // Inicializar listas de exercícios feitos para cada dia
    _exerciciosFeitosDia1 =
        List.generate(_exerciciosDia1.length, (index) => false);
    _exerciciosFeitosDia2 =
        List.generate(_exerciciosDia2.length, (index) => false);
    _exerciciosFeitosDia3 =
        List.generate(_exerciciosDia3.length, (index) => false);
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _exerciciosFeitosDia1 = List.generate(_exerciciosDia1.length, (index) {
        return _prefs.getBool('${_exerciciosDia1[index]}_$username') ?? false;
      });

      _exerciciosFeitosDia2 = List.generate(_exerciciosDia2.length, (index) {
        return _prefs.getBool('${_exerciciosDia2[index]}_$username') ?? false;
      });

      _exerciciosFeitosDia3 = List.generate(_exerciciosDia3.length, (index) {
        return _prefs.getBool('${_exerciciosDia3[index]}_$username') ?? false;
      });
    });
  }

  void _savePreferences() async {
    for (int i = 0; i < _exerciciosDia1.length; i++) {
      await _prefs.setBool(
          '${_exerciciosDia1[i]}_$username', _exerciciosFeitosDia1[i]);
    }

    for (int i = 0; i < _exerciciosDia2.length; i++) {
      await _prefs.setBool(
          '${_exerciciosDia2[i]}_$username', _exerciciosFeitosDia2[i]);
    }

    for (int i = 0; i < _exerciciosDia3.length; i++) {
      await _prefs.setBool(
          '${_exerciciosDia3[i]}_$username', _exerciciosFeitosDia3[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Exercícios'),
      ),
      body: ListView(
        children: [
          _buildExerciciosList(
              _exerciciosDia1, _exerciciosFeitosDia1, 'Dia 1 - Peito'),
          _buildExerciciosList(
              _exerciciosDia2, _exerciciosFeitosDia2, 'Dia 2 - Perna'),
          _buildExerciciosList(
              _exerciciosDia3, _exerciciosFeitosDia3, 'Dia 3 - Braço'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _savePreferences();
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildExerciciosList(
      List<String> exercicios, List<bool> exerciciosFeitos, String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        for (int i = 0; i < exercicios.length; i++)
          ListTile(
            title: Text(exercicios[i]),
            trailing: Checkbox(
              value: exerciciosFeitos[i],
              onChanged: (value) {
                setState(() {
                  exerciciosFeitos[i] = value!;
                });
              },
            ),
          ),
      ],
    );
  }
}
