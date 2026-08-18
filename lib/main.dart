import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// ============================================================
// PharmaNexux — a conexão inteligente do conhecimento farmacológico
// ============================================================

// ---------- Paleta ----------
class PxColors {
  static const petrol = Color(0xFF0B5D63); // principal
  static const deepBlue = Color(0xFF123B5D); // institucional / textos
  static const cyan = Color(0xFF27C2C9); // destaque / interativos
  static const offWhite = Color(0xFFF6F8F9); // fundo
  static const controlled = Color(0xFFB4452C); // alerta semântico (controlados)
  static const controlledBg = Color(0xFFFBEDE8);
}

void main() => runApp(const PharmaNexuxApp());

class PharmaNexuxApp extends StatelessWidget {
  const PharmaNexuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaNexux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: PxColors.offWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PxColors.petrol,
          primary: PxColors.petrol,
          secondary: PxColors.cyan,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: PxColors.petrol,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: PxColors.cyan.withOpacity(0.18),
          labelTextStyle: WidgetStatePropertyAll(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PxColors.deepBlue),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const SplashGate(),
    );
  }
}

// ---------- Dados ----------
class Med {
  final String nome, classe, funcao, uso, macete;
  final bool controlado;
  final List<String> sintomas;
  Med(this.nome, this.classe, this.funcao, this.uso, this.macete, this.controlado, this.sintomas);

  factory Med.fromJson(Map<String, dynamic> j) => Med(
        j['nome'], j['classe'], j['funcao'], j['uso_principal'], j['macete'],
        j['controlado'] == true, List<String>.from(j['sintomas'] ?? []),
      );
}

class Sintoma {
  final String id, nome, grupo;
  Sintoma(this.id, this.nome, this.grupo);
  factory Sintoma.fromJson(Map<String, dynamic> j) => Sintoma(j['id'], j['nome'], j['grupo']);
}

class CasoClinico {
  final int id;
  final String titulo, nivel, cenario, pergunta, explicacao;
  final List<String> opcoes;
  final int correta;
  CasoClinico(this.id, this.titulo, this.nivel, this.cenario, this.pergunta, this.opcoes, this.correta, this.explicacao);
  factory CasoClinico.fromJson(Map<String, dynamic> j) => CasoClinico(
      j['id'], j['titulo'], j['nivel'], j['cenario'], j['pergunta'],
      List<String>.from(j['opcoes']), j['correta'], j['explicacao']);
}

class QuizQ {
  final String pergunta, explicacao;
  final List<String> opcoes;
  final int correta;
  QuizQ(this.pergunta, this.opcoes, this.correta, this.explicacao);
  factory QuizQ.fromJson(Map<String, dynamic> j) =>
      QuizQ(j['pergunta'], List<String>.from(j['opcoes']), j['correta'], j['explicacao']);
}

class AppData {
  final List<Med> meds;
  final List<Sintoma> sintomas;
  final List<CasoClinico> casos;
  final List<QuizQ> quiz;
  AppData(this.meds, this.sintomas, this.casos, this.quiz);

  static Future<AppData> load() async {
    final medJson = jsonDecode(await rootBundle.loadString('assets/data/medicamentos.json'));
    final casosJson = jsonDecode(await rootBundle.loadString('assets/data/casos.json'));
    return AppData(
      (medJson['medicamentos'] as List).map((e) => Med.fromJson(e)).toList()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase())),
      (medJson['sintomas'] as List).map((e) => Sintoma.fromJson(e)).toList(),
      (casosJson['casos'] as List).map((e) => CasoClinico.fromJson(e)).toList(),
      (casosJson['quiz'] as List).map((e) => QuizQ.fromJson(e)).toList(),
    );
  }
}

// ---------- Logo (3 nós conectados) ----------
class NexusLogo extends StatelessWidget {
  final double size;
  final Color color;
  const NexusLogo({super.key, this.size = 64, this.color = PxColors.cyan});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _NexusPainter(color));
}

class _NexusPainter extends CustomPainter {
  final Color color;
  _NexusPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p1 = Offset(w * 0.5, w * 0.18);
    final p2 = Offset(w * 0.2, w * 0.78);
    final p3 = Offset(w * 0.8, w * 0.78);
    final line = Paint()
      ..color = color.withOpacity(0.75)
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p1, p2, line);
    canvas.drawLine(p2, p3, line);
    canvas.drawLine(p3, p1, line);
    final node = Paint()..color = color;
    for (final p in [p1, p2, p3]) {
      canvas.drawCircle(p, w * 0.115, node);
    }
    final inner = Paint()..color = Colors.white.withOpacity(0.9);
    for (final p in [p1, p2, p3]) {
      canvas.drawCircle(p, w * 0.045, inner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------- Splash + Disclaimer ----------
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  AppData? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppData.load().then((d) => setState(() => _data = d),
        onError: (e) => setState(() => _error = '$e'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PxColors.deepBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NexusLogo(size: 96),
                const SizedBox(height: 20),
                const Text('PharmaNexux',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text('a conexão inteligente do conhecimento farmacológico',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75))),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PxColors.cyan.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      const Row(children: [
                        Icon(Icons.info_outline, color: PxColors.cyan, size: 20),
                        SizedBox(width: 8),
                        Text('Aviso importante',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                        'Este aplicativo é uma ferramenta de estudo para alunos da área de '
                        'farmácia. As recomendações são baseadas exclusivamente na apostila de '
                        'medicamentos (AMP e FR) e têm finalidade pedagógica — não constituem '
                        'prescrição médica, diagnóstico clínico ou orientação para uso real em '
                        'pacientes. Toda decisão sobre dispensação, prescrição ou administração '
                        'de medicamentos deve ser tomada por profissional de saúde habilitado, '
                        'seguindo os protocolos da instituição e a legislação vigente.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                if (_error != null)
                  Text('Erro ao carregar dados: $_error',
                      style: const TextStyle(color: Colors.redAccent))
                else if (_data == null)
                  const CircularProgressIndicator(color: PxColors.cyan)
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: PxColors.cyan,
                        foregroundColor: PxColors.deepBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => HomeShell(data: _data!))),
                      child: const Text('Entendi, começar a estudar'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Shell com abas ----------
class HomeShell extends StatefulWidget {
  final AppData data;
  const HomeShell({super.key, required this.data});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BibliotecaPage(data: widget.data),
      AssistentePage(data: widget.data),
      CasosPage(data: widget.data),
      QuizPage(data: widget.data),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const NexusLogo(size: 26),
          const SizedBox(width: 10),
          Text(['Biblioteca', 'Assistente de Sintomas', 'Casos Clínicos', 'Quiz'][_tab]),
        ]),
      ),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: PxColors.petrol), label: 'Biblioteca'),
          NavigationDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub, color: PxColors.petrol), label: 'Assistente'),
          NavigationDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology, color: PxColors.petrol), label: 'Casos'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz, color: PxColors.petrol), label: 'Quiz'),
        ],
      ),
    );
  }
}

// ---------- Widgets compartilhados ----------
class ControlledBadge extends StatelessWidget {
  const ControlledBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: PxColors.controlledBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PxColors.controlled.withOpacity(0.5)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_outline, size: 12, color: PxColors.controlled),
          SizedBox(width: 4),
          Text('CONTROLADO',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: PxColors.controlled)),
        ]),
      );
}

class MedCard extends StatelessWidget {
  final Med med;
  final List<String>? matchedSintomas;
  final Map<String, String>? sintomaNomes;
  const MedCard({super.key, required this.med, this.matchedSintomas, this.sintomaNomes});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          iconColor: PxColors.cyan,
          collapsedIconColor: PxColors.deepBlue,
          title: Row(children: [
            Expanded(
              child: Text(med.nome,
                  style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: PxColors.deepBlue)),
            ),
            if (med.controlado) const ControlledBadge(),
          ]),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(med.classe,
                style: TextStyle(fontSize: 13, color: PxColors.petrol.withOpacity(0.9))),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('Função', med.funcao),
                  _field('Principal uso', med.uso),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PxColors.cyan.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.lightbulb_outline, size: 18, color: PxColors.petrol),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('“${med.macete}”',
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: PxColors.deepBlue)),
                      ),
                    ]),
                  ),
                  if (matchedSintomas != null && matchedSintomas!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Por que apareceu aqui:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: PxColors.deepBlue.withOpacity(0.7))),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: matchedSintomas!
                          .map((s) => Chip(
                                label: Text(sintomaNomes?[s] ?? s,
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor: PxColors.cyan.withOpacity(0.15),
                                side: BorderSide.none,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13.5, color: PxColors.deepBlue, height: 1.45, fontFamily: 'Inter'),
            children: [
              TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: value),
            ],
          ),
        ),
      );
}

// ---------- Aba 1: Biblioteca ----------
class BibliotecaPage extends StatefulWidget {
  final AppData data;
  const BibliotecaPage({super.key, required this.data});
  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  String _busca = '';
  int _filtro = 0; // 0 todos, 1 não controlados, 2 controlados

  @override
  Widget build(BuildContext context) {
    var meds = widget.data.meds.where((m) {
      if (_filtro == 1 && m.controlado) return false;
      if (_filtro == 2 && !m.controlado) return false;
      if (_busca.isEmpty) return true;
      final q = _removeAccents(_busca.toLowerCase());
      return _removeAccents('${m.nome} ${m.classe} ${m.funcao} ${m.uso}'.toLowerCase()).contains(q);
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        child: TextField(
          onChanged: (v) => setState(() => _busca = v),
          decoration: InputDecoration(
            hintText: 'Buscar medicamento, classe ou uso…',
            prefixIcon: const Icon(Icons.search, color: PxColors.petrol),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(children: [
          _chip('Todos (${widget.data.meds.length})', 0),
          const SizedBox(width: 8),
          _chip('Não controlados', 1),
          const SizedBox(width: 8),
          _chip('Controlados', 2),
        ]),
      ),
      Expanded(
        child: meds.isEmpty
            ? const Center(child: Text('Nenhum medicamento encontrado.'))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: meds.length,
                itemBuilder: (_, i) => MedCard(med: meds[i]),
              ),
      ),
    ]);
  }

  Widget _chip(String label, int value) => ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _filtro == value,
        selectedColor: PxColors.cyan.withOpacity(0.25),
        onSelected: (_) => setState(() => _filtro = value),
      );

  String _removeAccents(String s) {
    const from = 'áàãâäéèêëíìîïóòõôöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    return s;
  }
}

// ---------- Aba 2: Assistente de sintomas ----------
class AssistentePage extends StatefulWidget {
  final AppData data;
  const AssistentePage({super.key, required this.data});
  @override
  State<AssistentePage> createState() => _AssistentePageState();
}

class _AssistentePageState extends State<AssistentePage> {
  final Set<String> _selecionados = {};

  @override
  Widget build(BuildContext context) {
    final grupos = <String, List<Sintoma>>{};
    for (final s in widget.data.sintomas) {
      grupos.putIfAbsent(s.grupo, () => []).add(s);
    }
    final sintomaNomes = {for (final s in widget.data.sintomas) s.id: s.nome};

    // motor de regras: ranqueia por nº de sintomas compatíveis
    final resultados = <(Med, List<String>)>[];
    if (_selecionados.isNotEmpty) {
      for (final m in widget.data.meds) {
        final match = m.sintomas.where(_selecionados.contains).toList();
        if (match.isNotEmpty) resultados.add((m, match));
      }
      resultados.sort((a, b) => b.$2.length.compareTo(a.$2.length));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PxColors.deepBlue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Selecione os sintomas/quadro do paciente fictício. O PharmaNexux cruza a seleção '
            'com a apostila e mostra os medicamentos relacionados — com a justificativa. '
            'Ferramenta de estudo: não substitui avaliação profissional.',
            style: TextStyle(fontSize: 12.5, color: PxColors.deepBlue, height: 1.45),
          ),
        ),
        const SizedBox(height: 10),
        ...grupos.entries.map((e) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Text(e.key,
                      style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: PxColors.petrol)),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: e.value.map((s) {
                    final sel = _selecionados.contains(s.id);
                    return FilterChip(
                      label: Text(s.nome, style: const TextStyle(fontSize: 12)),
                      selected: sel,
                      selectedColor: PxColors.cyan.withOpacity(0.30),
                      checkmarkColor: PxColors.deepBlue,
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() {
                        sel ? _selecionados.remove(s.id) : _selecionados.add(s.id);
                      }),
                    );
                  }).toList(),
                ),
              ],
            )),
        const SizedBox(height: 18),
        if (_selecionados.isNotEmpty) ...[
          Row(children: [
            Text('Medicamentos relacionados (${resultados.length})',
                style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: PxColors.deepBlue)),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _selecionados.clear()),
              child: const Text('Limpar', style: TextStyle(color: PxColors.petrol)),
            ),
          ]),
          if (resultados.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Nenhum medicamento da apostila corresponde a essa combinação.'),
            )
          else
            ...resultados.map((r) => Padding(
                  padding: EdgeInsets.zero,
                  child: MedCard(med: r.$1, matchedSintomas: r.$2, sintomaNomes: sintomaNomes),
                )),
        ],
      ],
    );
  }
}

// ---------- Aba 3: Casos clínicos ----------
class CasosPage extends StatelessWidget {
  final AppData data;
  const CasosPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: data.casos.length,
      itemBuilder: (_, i) {
        final c = data.casos[i];
        final cor = switch (c.nivel) {
          'Básico' => PxColors.cyan,
          'Intermediário' => PxColors.petrol,
          _ => PxColors.deepBlue,
        };
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: cor.withOpacity(0.15),
              child: Text('${c.id}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: cor)),
            ),
            title: Text(c.titulo,
                style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: PxColors.deepBlue)),
            subtitle: Text(c.nivel, style: TextStyle(fontSize: 12, color: cor)),
            trailing: const Icon(Icons.chevron_right, color: PxColors.cyan),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CasoDetalhe(caso: c))),
          ),
        );
      },
    );
  }
}

class CasoDetalhe extends StatefulWidget {
  final CasoClinico caso;
  const CasoDetalhe({super.key, required this.caso});
  @override
  State<CasoDetalhe> createState() => _CasoDetalheState();
}

class _CasoDetalheState extends State<CasoDetalhe> {
  int? _resposta;

  @override
  Widget build(BuildContext context) {
    final c = widget.caso;
    return Scaffold(
      appBar: AppBar(title: Text('Caso ${c.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(c.titulo,
              style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: PxColors.deepBlue)),
          const SizedBox(height: 4),
          Text(c.nivel, style: const TextStyle(color: PxColors.petrol, fontSize: 13)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(c.cenario, style: const TextStyle(fontSize: 14.5, height: 1.55, color: PxColors.deepBlue)),
          ),
          const SizedBox(height: 16),
          Text(c.pergunta,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15.5, color: PxColors.deepBlue)),
          const SizedBox(height: 10),
          ...List.generate(c.opcoes.length, (i) {
            Color? bg;
            IconData? icon;
            if (_resposta != null) {
              if (i == c.correta) {
                bg = const Color(0xFFE4F4EA);
                icon = Icons.check_circle;
              } else if (i == _resposta) {
                bg = PxColors.controlledBg;
                icon = Icons.cancel;
              }
            }
            return Card(
              color: bg ?? Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(c.opcoes[i], style: const TextStyle(fontSize: 14.5, color: PxColors.deepBlue)),
                trailing: icon != null
                    ? Icon(icon,
                        color: i == c.correta ? const Color(0xFF1E7A46) : PxColors.controlled)
                    : null,
                onTap: _resposta == null ? () => setState(() => _resposta = i) : null,
              ),
            );
          }),
          if (_resposta != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PxColors.cyan.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PxColors.cyan.withOpacity(0.4)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_resposta == c.correta ? '✔ Correto!' : '✘ Não foi dessa vez.',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _resposta == c.correta
                            ? const Color(0xFF1E7A46)
                            : PxColors.controlled)),
                const SizedBox(height: 8),
                Text(c.explicacao,
                    style: const TextStyle(fontSize: 13.5, height: 1.55, color: PxColors.deepBlue)),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => setState(() => _resposta = null),
                  icon: const Icon(Icons.refresh, color: PxColors.petrol),
                  label: const Text('Tentar novamente', style: TextStyle(color: PxColors.petrol)),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------- Aba 4: Quiz ----------
class QuizPage extends StatefulWidget {
  final AppData data;
  const QuizPage({super.key, required this.data});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizQ>? _rodada;
  int _idx = 0;
  int _acertos = 0;
  int? _resposta;

  void _iniciar() {
    final all = List<QuizQ>.from(widget.data.quiz)..shuffle(Random());
    setState(() {
      _rodada = all.take(10).toList();
      _idx = 0;
      _acertos = 0;
      _resposta = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_rodada == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const NexusLogo(size: 72, color: PxColors.petrol),
            const SizedBox(height: 18),
            const Text('Quiz PharmaNexux',
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: PxColors.deepBlue)),
            const SizedBox(height: 8),
            Text('10 perguntas sorteadas da apostila.\nClasses, macetes e usos principais.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: PxColors.deepBlue.withOpacity(0.7))),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: PxColors.cyan,
                foregroundColor: PxColors.deepBlue,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              onPressed: _iniciar,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Começar quiz',
                  style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ]),
        ),
      );
    }

    if (_idx >= _rodada!.length) {
      final pct = (_acertos / _rodada!.length * 100).round();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$pct%',
                style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: PxColors.petrol)),
            Text('$_acertos de ${_rodada!.length} acertos',
                style: const TextStyle(fontSize: 16, color: PxColors.deepBlue)),
            const SizedBox(height: 10),
            Text(
                pct >= 80
                    ? 'Excelente! Conhecimento conectado. 🧠'
                    : pct >= 50
                        ? 'Bom caminho — revise os macetes na Biblioteca.'
                        : 'Continue estudando: a Biblioteca e os Casos ajudam muito.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: PxColors.deepBlue.withOpacity(0.75))),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: PxColors.cyan, foregroundColor: PxColors.deepBlue),
              onPressed: _iniciar,
              child: const Text('Jogar de novo'),
            ),
            TextButton(
              onPressed: () => setState(() => _rodada = null),
              child: const Text('Voltar ao início', style: TextStyle(color: PxColors.petrol)),
            ),
          ]),
        ),
      );
    }

    final q = _rodada![_idx];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Text('Pergunta ${_idx + 1}/${_rodada!.length}',
              style: const TextStyle(
                  fontFamily: 'Manrope', fontWeight: FontWeight.w700, color: PxColors.petrol)),
          const Spacer(),
          Text('Acertos: $_acertos', style: const TextStyle(color: PxColors.deepBlue)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_idx + 1) / _rodada!.length,
          color: PxColors.cyan,
          backgroundColor: PxColors.cyan.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 18),
        Text(q.pergunta,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: PxColors.deepBlue, height: 1.45)),
        const SizedBox(height: 12),
        ...List.generate(q.opcoes.length, (i) {
          Color? bg;
          if (_resposta != null) {
            if (i == q.correta) bg = const Color(0xFFE4F4EA);
            if (i == _resposta && i != q.correta) bg = PxColors.controlledBg;
          }
          return Card(
            color: bg ?? Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text(q.opcoes[i], style: const TextStyle(fontSize: 14.5, color: PxColors.deepBlue)),
              onTap: _resposta == null
                  ? () => setState(() {
                        _resposta = i;
                        if (i == q.correta) _acertos++;
                      })
                  : null,
            ),
          );
        }),
        if (_resposta != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PxColors.cyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(q.explicacao,
                style: const TextStyle(fontSize: 13.5, height: 1.5, color: PxColors.deepBlue)),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: PxColors.cyan, foregroundColor: PxColors.deepBlue),
            onPressed: () => setState(() {
              _idx++;
              _resposta = null;
            }),
            child: Text(_idx + 1 >= _rodada!.length ? 'Ver resultado' : 'Próxima pergunta'),
          ),
        ],
      ],
    );
  }
}
