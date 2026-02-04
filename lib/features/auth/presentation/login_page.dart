
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';
import '../../home/presentation/main_screen.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Pattern Background Area (Top 25%)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  // Simple radial gradient pattern simulation
                  gradient: RadialGradient(
                    colors: [Colors.grey.shade300, Theme.of(context).colorScheme.surface],
                    radius: 0.5,
                    tileMode: TileMode.repeated,
                  ),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFFF6F6F8)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Transform.translate(
                offset: const Offset(0, -60), // Pull up effect
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Icon Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50), // primary-vibrant
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade900.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.school, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Portal do Aluno',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111218),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestão acadêmica simplificada',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5D6389),
                        ),
                      ),
                      const SizedBox(height: 32),
          
                      // Inputs
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text('E-mail', style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'exemplo@universidade.edu',
                              suffixIcon: Icon(Icons.mail_outline, color: Color(0xFF5D6389)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Senha', style: TextStyle(fontWeight: FontWeight.w500)),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Funcionalidade de recuperação de senha em desenvolvimento.')),
                                  );
                                }, // Forgot password placeholder
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Esqueceu a senha?',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              hintText: 'Sua senha de acesso',
                              suffixIcon: Icon(Icons.lock_outline, color: Color(0xFF5D6389)),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
          
                      // Submit Button
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: _login,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Entrar'),
                              SizedBox(width: 8),
                              Icon(Icons.login, size: 20),
                            ],
                          ),
                        ),
                        
                      const SizedBox(height: 32),
                      
                      // Biometry
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Biometria não configurada neste dispositivo.')),
                          );
                        },
                        icon: const Icon(Icons.fingerprint, size: 32, color: Color(0xFF5D6389)),
                        label: const Text(
                          'Usar biometria',
                          style: TextStyle(color: Color(0xFF5D6389)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ainda não tem conta? ',
              style: TextStyle(color: Color(0xFF5D6389), fontSize: 13),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text(
                'Cadastre-se',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
