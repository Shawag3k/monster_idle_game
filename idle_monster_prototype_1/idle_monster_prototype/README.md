# Idle Monster Prototype

Protótipo mínimo e vibecodável do loop central do jogo. Sem arte (retângulos
coloridos), sem mundos/mapas ainda — só o essencial pra validar se o combate
e a captura fazem sentido.

## Como abrir

1. Instale o **Godot 4** (godotengine.org, versão estável mais recente, "Standard" ou ".NET" — este projeto usa só GDScript, então "Standard" é suficiente).
2. Abra o Godot, clique em **Importar**, selecione a pasta `idle_monster_prototype` (o arquivo `project.godot` dentro dela).
3. Aperte **F5** (ou o botão de Play no canto superior direito) para rodar.

## Controles

- Ao abrir, escolha seu monstrinho inicial: **Bolinha Azul (Água)**, **Verde (Planta)** ou **Vermelha (Fogo)**.
- Depois escolhe uma **Fase** na tela de Mundo → Mapa → Fase (setas `<`/`>` trocam de mundo, os botões "Mapa 1"–"Mapa 5" trocam de mapa dentro do mundo, e a grade de baixo mostra as 10 fases daquele mapa — fases/mapas/mundos bloqueados aparecem desabilitados).
- O combate é automático: seu monstrinho (círculo, colorido pelo tipo escolhido) ataca sozinho o inimigo mais próximo dentro do alcance.
- Inimigos (triângulos, coloridos pelo elemento) vêm andando até o jogador e atacam também.
  - No Mundo 1 (Fácil), ondas 1 a 3 só têm inimigos **Normal** (triângulo cinza) — sempre causam e sofrem dano 1x, sem vantagem/desvantagem de tipo. Bom pra testar o combate puro, sem a variável de elemento.
  - Daí em diante os inimigos vêm com tipos elementais, puxados com mais frequência pro(s) tipo(s) dominante(s) do bioma do mapa atual (mostrado na tela de seleção).
  - A última onda de cada fase é um mini-boss (stats x1.8); na fase 10 (Boss do Mapa) ele vem x5 mais forte, e derrotá-lo libera o próximo mapa.
- Pressione **C** para tentar capturar o inimigo mais próximo que estiver com HP abaixo de 30%. A chance de sucesso depende da raridade dele (mostrada no log de eventos na tela).
- Botão **"Voltar ao Mapa"** (canto superior direito durante o combate, ou na tela de fase concluída) leva de volta pra seleção de fase a qualquer momento.

**Nota:** a captura por HP baixo é só o método de teste atual. O sistema de **petisco** (item que aumenta a chance de captura por afinidade de tipo, usado no confronto com o chefe de fase) já foi desenhado no documento de design, mas ainda não está implementado neste protótipo.

## O que já está implementado (ligado ao Game Design Document)

- Sistema de tipos e multiplicadores (`TypeChart.gd` — seção 3 do documento)
- Fórmula de dano com defesa, tipo e variância (`Creature.gd` — seção 5.2)
- Cooldown de ataque por velocidade de ataque (seção 5.2)
- Estrutura Mundo → Mapa → Fase, com ondas por fase = 5×mundo, mini-boss (x1.8) ao fim de cada fase e Boss de Mapa (x5) na fase 10, e regras de desbloqueio de mapa/mundo (`GameData.gd`, `ProgressManager.gd`, `WaveManager.gd` — seção 4)
- Biomas cíclicos por mapa influenciando o tipo dos inimigos que aparecem (`GameData.gd` — seção 12)
- Tela de seleção de Mundo/Mapa/Fase (`MapSelect.gd`)
- Chance de captura por raridade (seção 6)
- Chance de aparição/raridade dos inimigos de cada onda (seção 6, tabela ajustada)

## O que **não** está implementado ainda (próximas iterações)

- Progresso de Mundo/Mapa/Fase não é salvo em disco (reinicia a cada sessão)
- Time de 3 criaturas / Formação com slots e regras de alvo (seção 6) — hoje é só 1 monstrinho
- Captura via Petisco no chefe de fase (seção 7.2) — hoje é captura por HP baixo em qualquer inimigo
- Runas, itens, mercado, economia (ouro/XP)
- Cura em zona segura / monstro curador
- Progressão de nível e evolução de criaturas
- Roster real de criaturas (hoje são só formas/cores por tipo, sem nome de espécie)
- Arte (sprites reais, pixel art)

## Sugestão de próximo passo

Peça pra IA (Claude Code, por exemplo) evoluir isso **um sistema por vez**,
mantendo os arquivos separados como estão (`Creature.gd`, `Enemy.gd`,
`WaveManager.gd` etc.) — isso é o que vai deixar o projeto fácil de manter
via vibecoding conforme cresce.
