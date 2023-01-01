import 'package:artemis/artemis.dart';
import 'package:compare_graphql_packages_sample/artemis/pokemon_api.dart';
import 'package:compare_graphql_packages_sample/define.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ArtemisApp());
}

class ArtemisApp extends StatelessWidget {
  const ArtemisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artemis Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PokemonListPage(),
    );
  }
}

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final client = ArtemisClient(apiUrl);

  Future<GraphQLResponse<KantoPokemon$Query>>? requestData;

  @override
  void initState() {
    super.initState();
    requestData = requestPokemonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('artemis demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => reloadPokemonData(),
          ),
        ],
      ),
      body: FutureBuilder(
        future: requestData,
        builder: ((context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final response = snapshot.data;
          final pokemonsData = response?.data?.pokemons;

          if (response == null || response.hasErrors || pokemonsData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('データを取得できませんでした.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      requestData = requestPokemonData();
                    }),
                    child: const Text('再取得'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemBuilder: (context, index) {
              final pokemon = pokemonsData[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _PokemonCard(pokemon: pokemon!),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 0.5),
            itemCount: pokemonsData.length,
          );
        }),
      ),
    );
  }

  Future<GraphQLResponse<KantoPokemon$Query>> requestPokemonData() =>
      client.execute(KantoPokemonQuery());

  void reloadPokemonData() => setState(() {
        requestData = requestPokemonData();
      });
}

class _PokemonCard extends StatelessWidget {
  const _PokemonCard({required this.pokemon});

  final PokeFragmentMixin pokemon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          pokemon.image!,
          height: 120,
        ),
        title: Text(pokemon.name!),
        subtitle: Text(pokemon.number!),
      ),
    );
  }
}
