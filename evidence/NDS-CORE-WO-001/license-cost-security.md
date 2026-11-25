# Licenças, custo e segurança — NDS-CORE-WO-001/CD-01

## Resultado da revisão F02

| Componente | Fonte e qualificação | Decisão para esta fase |
|---|---|---|
| Remotion 4.0.547 | [LICENSE.md oficial da tag v4.0.547](https://raw.githubusercontent.com/remotion-dev/remotion/v4.0.547/LICENSE.md) e [release da mesma versão](https://github.com/remotion-dev/remotion/releases/tag/v4.0.547). A licença gratuita permite uso individual, inclusive criação comercial de vídeos/imagens; organizações com fins lucrativos fora da categoria gratuita precisam de licença empresarial. | Qualificado para o uso individual declarado pelo usuário, sem custo adicional. Não houve compra nem aceite de licença. O repositório GitHub sob NexLabsTech não prova por si só a identidade da entidade que explorará o produto; se uma empresa fora da elegibilidade gratuita for a usuária real, essa entidade precisa de licença comercial antes desse uso. |
| Kokoro 82M e voz `af_heart` | O [model card fixado](https://huggingface.co/hexgrad/Kokoro-82M/blob/f3ff3571791e39611d31c381e3a41a3af07b4987/README.md) declara Apache-2.0 para os pesos e fontes variadas para treinamento. Ele não identifica a origem/licença por voice pack. A [issue oficial #376](https://github.com/hexgrad/kokoro/issues/376) pergunta especificamente a proveniência de `af_heart`; em 25/11/2026 permanecia sem resposta qualificada do mantenedor. | A licença dos pesos foi verificada, mas não comprova direitos da voz nem dos dados por voz. O uso de `af_heart` fica restrito a smoke técnico local; não liberar áudio Kokoro para uso comercial ou distribuição enquanto a proveniência/direitos não forem documentados. Modelo e voz foram apenas lidos do cache fixado; nenhuma mídia foi versionada. |
| Alternativa candidata se Kokoro não passar no gate | Coqui `tts_models/en/ljspeech/vits`: o [catálogo oficial do Coqui](https://github.com/coqui-ai/TTS/blob/dev/TTS/.models.json) lista os pesos VITS sob Apache-2.0; o [LJ Speech Dataset](https://keithito.com/LJ-Speech-Dataset/) declara áudio, texto e anotações em domínio público e gravação por Linda Johnson. O código Coqui é MPL-2.0. | Proposta gratuita para avaliação futura porque os direitos específicos de `af_heart` continuam sem confirmação. Não foi baixada, instalada ou testada, e não substitui Kokoro nem altera a arquitetura. Antes de adotá-la, fixar versão/hash do modelo, revisar dependências e compatibilidade Windows/Python e obter revisão independente da licença e da voz gerada. |
| Kokoro G2P / eSpeak NG | [Wrapper](https://github.com/thewh1teagle/espeakng-loader/blob/main/LICENSE) MIT; biblioteca/dados upstream [eSpeak NG](https://github.com/espeak-ng/espeak-ng) GPL-3.0-or-later. | Uso local de qualificação. Não redistribuir binários/voz do eSpeak sem cumprir GPL; revisar obrigações antes de empacotamento. |
| Faster Whisper | [Repositório oficial](https://github.com/SYSTRAN/faster-whisper), MIT. Modelo `Systran/faster-whisper-tiny.en` fixado em `0d3d19a32d3338f10357c0889762bd8d64bbdeba`. | Smoke CPU/int8 local, sem API. SHA-256 do modelo no log CD-01. |
| PyAV | [PyPI oficial](https://pypi.org/project/av/18.1.1/); lock fixa `av==18.1.1`. | Versão 19.0.2 era incompatível com Faster Whisper 1.2.1; corrigida antes deste CD. `pip check` e smoke local passaram. |
| FFmpeg / ffprobe | [Aviso legal oficial](https://ffmpeg.org/legal.html). Binário preexistente inclui `--enable-gpl` e libx264. | Uso local; não redistribuir o binário. O smoke real confirmou codificação H.264/AAC. Patentes/redistribuição H.264 não foram qualificadas. |
| SQLite | [Copyright oficial](https://www.sqlite.org/copyright.html), domínio público; biblioteca da stdlib Python. | Transação, rollback, commit e reabertura local aprovados; DB efêmero no sandbox. |
| ImageGen | [Documentação oficial](https://developers.openai.com/learn/imagegen) não comprova entitlement de custo zero para esta sessão. | Não chamada. A fixture PNG sintética local cobre importação. Nenhuma API, trial ou crédito foi iniciado. |
| GitHub Actions / Socket | [Billing oficial Actions](https://docs.github.com/en/actions/concepts/billing-and-usage), [runners hosted](https://docs.github.com/en/actions/reference/runners/github-hosted-runners) e [preços Socket](https://socket.dev/pricing). | Workflow existente `ubuntu-latest` em repositório público; custo adicional zero. Checks Socket são integrações existentes. Nada foi alterado em cobrança, plano ou regras de acesso. |

## Lockfiles e cadeia de suprimentos (F04)

- Python usa `requirements-lock.txt` e venv Windows já existente. `pip install --no-index --no-deps --dry-run --requirement requirements-lock.txt`, `pip check` e `pip freeze --all` passaram no ambiente isolado; todos os pins estavam satisfeitos, sem download nem reinstalação. SHA-256 do lock: `18292BA1239AE6BA871BEC476D0A1ACEA42D0FFB3173640CD481ABE145F7AB30`.
- Remotion usa `package-lock.json`. `npm ci --dry-run --ignore-scripts --no-audit --no-fund --prefer-offline` e `npm ls --depth=0` passaram sem apagar/reinstalar `node_modules`; 291 entradas remotas têm `integrity`, zero fora de `registry.npmjs.org`; scripts lifecycle desativados. Hash do lock: `171B466310ECDD6B7E38E48EFA0CF2497D792B149E7E1600B38AE3867F1843ED`. As versões instaladas verificadas diretamente nos manifests são `@remotion/cli@4.0.547`, `remotion@4.0.547`, `react@19.3.1`, `react-dom@19.3.1`.
- Logs de comandos e hashes em `qualification/logs/CD-01/`. Os caches npm/Hugging Face e o venv preexistentes foram reutilizados. Nenhum pacote foi reinstalado durante CD-01; nenhum script de terceiro foi habilitado.

## Custos e dados

- Custo adicional: US$ 0. Nenhum serviço, chamada de API paga, compra, crédito, assinatura, runner privado ou publicação foi usado.
- Os modelos TTS/ASR vêm de snapshots já em cache; o smoke usa `HF_HUB_OFFLINE=1` e caminhos locais fixados. Não executa chamada de rede ou API.
- O ambiente filho limpa as variáveis herdadas e permite apenas nomes adicionais aprovados; TEMP/TMP/HOME/USERPROFILE/APPDATA ficam em novo sandbox por execução. Os logs guardam caminhos relativos, hashes e transcrição sintética, sem caminhos pessoais ou segredos.
- Evidências não incluem modelo, WAV, MP4 ou credenciais. A fixture de importação é sintética.

## Rollback e limites

Dependências e modelos ficam em runtime local isolado preexistente. Os smokes criam subdiretórios novos e exclusivos em `qualification/.runtime/runs`; a árvore runtime é ignorada pelo Git. O binário FFmpeg é preexistente e inalterado. A contribuição é reversível ao fechar a PR/reverter o commit. Não houve migração de dados nem mudança persistente do sistema.

**Gate comercial residual:** a elegibilidade individual Remotion está qualificada para o escopo declarado. A proveniência comercial da voz Kokoro `af_heart` não está comprovada; não usar Kokoro em conteúdo comercial até obter evidência ou aprovar e qualificar outra voz/modelo. Esta limitação fica para o auditor independente.
