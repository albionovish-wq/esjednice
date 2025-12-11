import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esjednice/dizajn_sistem/dizajn_sistem.dart';
import 'package:esjednice/provideri/global.dart';

class PrijavaEkran extends ConsumerStatefulWidget {
  const PrijavaEkran({Key? key}) : super(key: key);

  @override
  ConsumerState<PrijavaEkran> createState() => _PrijavaEkranState();
}

class _PrijavaEkranState extends ConsumerState<PrijavaEkran> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _imeController.dispose();
    _prezimeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (user != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUpWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
        ime: _imeController.text,
        prezime: _prezimeController.text,
      );

      if (user != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.lightGray,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppDesign.spacingL),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.cardRadius),
              side: const BorderSide(color: AppDesign.borderGray),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDesign.spacingL),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'eSjednice',
                      style: AppDesign.pageTitle,
                    ),
                    const SizedBox(height: AppDesign.spacingL),
                    Text(
                      _isSignUp ? 'Kreiraj račun' : 'Prijava',
                      style: AppDesign.cardTitle,
                    ),
                    const SizedBox(height: AppDesign.spacingL),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(AppDesign.spacingM),
                        margin: const EdgeInsets.only(bottom: AppDesign.spacingM),
                        decoration: BoxDecoration(
                          color: AppDesign.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDesign.cardRadius),
                          border: Border.all(color: AppDesign.errorRed),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: AppDesign.bodyText.copyWith(
                            color: AppDesign.errorRed,
                          ),
                        ),
                      ),
                    if (_isSignUp) ...[
                      TextField(
                        controller: _imeController,
                        decoration: const InputDecoration(
                          labelText: 'Ime',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: AppDesign.spacingM),
                      TextField(
                        controller: _prezimeController,
                        decoration: const InputDecoration(
                          labelText: 'Prezime',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: AppDesign.spacingM),
                    ],
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: AppDesign.spacingM),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Lozinka',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: AppDesign.spacingL),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_isSignUp ? _handleSignUp : _handleSignIn),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isSignUp ? 'Kreiraj račun' : 'Prijava'),
                    ),
                    const SizedBox(height: AppDesign.spacingM),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'Već imaš račun? Prijava'
                            : 'Nemaš račun? Kreiraj',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
