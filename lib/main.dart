import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_2_rest/graphql_2_rest.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GraphQL Rest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GraphQL Rest'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Map<String, dynamic>>> sendRequest() async {
    var client = http.Client();
    const queryBuilder = GraphQLQueryBuilder();
    try {
      var response = await client.post(
          Uri.parse('https://qutzykcdiptuzoqspbte.supabase.co/graphql/v1'),
          body: queryBuilder.build(query),
          headers: {
            'apikey':
                'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1dHp5a2NkaXB0dXpvcXNwYnRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTEwMzg3OTMsImV4cCI6MjAwNjYxNDc5M30.3mh_usRMxOnqk2-cbEVBjNVfyxgCAl_IdjoSa9eDhHg',
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1dHp5a2NkaXB0dXpvcXNwYnRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTEwMzg3OTMsImV4cCI6MjAwNjYxNDc5M30.3mh_usRMxOnqk2-cbEVBjNVfyxgCAl_IdjoSa9eDhHg',
          });
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      var data = decodedResponse['data'] as Map;
      var todosCollection = data['todosCollection'] as Map;
      var edges = todosCollection['edges'] as List;
      return edges.map((e) => e['node'] as Map<String, dynamic>).toList();
    } finally {
      client.close();
    }
  }

  final query = '''query TodosCollection{
    todosCollection {
        edges {
            node {
                nodeId
                id
                created_at
                title
                description
                is_done
            }
        }
    }
  }''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: sendRequest(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            }
            return ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data?[index]['title']),
                  subtitle: Text(snapshot.data?[index]['description']),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemCount: snapshot.data?.length ?? 0,
            );
          },
        ),
      ),
    );
  }
}
