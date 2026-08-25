import 'package:flutter/material.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/profile_controller.dart';

class LoginProfileScreen extends StatefulWidget {
  final ProfileController profileController;
  final FavoritesController favoritesController;

  const LoginProfileScreen({
    super.key,
    required this.profileController,
    required this.favoritesController,
  });

  @override
  State<LoginProfileScreen> createState() => _LoginProfileScreenState();
}

class _LoginProfileScreenState extends State<LoginProfileScreen> {
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  void _updateControllers() {
    final user = widget.profileController.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _avatarController.text = user.avatarUrl;
    } else {
      _nameController.clear();
      _avatarController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _save() async {
    final success = await widget.profileController.saveProfile(
      _nameController.text,
      _avatarController.text,
    );

    if (!mounted) return;

    if (success) {
      _updateControllers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil ativado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe um nome válido.')),
      );
    }
  }

  void _selectSavedProfile(UserProfile profile) async {
    await widget.profileController.selectProfile(profile);
    if (!mounted) return;
    _updateControllers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bem-vindo de volta, ${profile.name}!')),
    );
  }

  void _logout() async {
    final success = await widget.profileController.logout();
    if (!mounted) return;
    if (success) {
      _nameController.clear();
      _avatarController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão encerrada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.profileController,
      builder: (context, _) {
        final user = widget.profileController.currentUser;
        final savedProfiles = widget.profileController.savedProfiles;
        final isLoading = widget.profileController.isLoading;

        final avatarUrl = user?.avatarUrl.trim() ?? '';

        return Scaffold(
          appBar: AppBar(title: const Text('Meu Perfil')),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (user != null) ...[
                        Center(
                          child: avatarUrl.isNotEmpty &&
                                  Uri.tryParse(avatarUrl)?.hasAbsolutePath == true
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(avatarUrl),
                                  onBackgroundImageError: (error, stackTrace) {},
                                )
                              : const CircleAvatar(
                                  radius: 40,
                                  child: Icon(Icons.person, size: 40),
                                ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome de Usuário *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _avatarController,
                          decoration: const InputDecoration(
                            labelText: 'URL da Imagem de Perfil (Opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _save,
                          child: const Text('Salvar Alterações'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _logout,
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Sair da Conta'),
                        ),
                      ] else ...[
                        if (savedProfiles.isNotEmpty) ...[
                          const Text(
                            'Selecione um perfil existente:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: savedProfiles.length,
                            itemBuilder: (context, index) {
                              final p = savedProfiles[index];
                              final pAvatar = p.avatarUrl.trim();
                              return Card(
                                child: ListTile(
                                  leading: pAvatar.isNotEmpty &&
                                          Uri.tryParse(pAvatar)?.hasAbsolutePath == true
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(pAvatar),
                                          onBackgroundImageError: (error, stackTrace) {},
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.person),
                                        ),
                                  title: Text(p.name),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => _selectSavedProfile(p),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 32),
                        ],
                        const Text(
                          'Ou entre informando seu nome:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome de Usuário *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _avatarController,
                          decoration: const InputDecoration(
                            labelText: 'URL da Imagem de Perfil (Opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _save,
                          child: const Text('Entrar / Criar Perfil'),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}