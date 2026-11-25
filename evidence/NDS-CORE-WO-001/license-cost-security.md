# Licenças, custo e segurança — NDS-CORE-WO-001

## Decisões verificadas

| Componente | Evidência/licença | Uso nesta fase |
|---|---|---|
| Remotion 4.0.547 | [FAQ oficial de licença](https://www.remotion.dev/docs/license/faq); condição gratuita aplicável a avaliação ainda não comercial | CLI oficial e fixture sintética local; sem publicação ou render comercial. Revalidar licença antes de qualquer uso produtivo/comercial. |
| Kokoro 82M | [Model card oficial](https://huggingface.co/hexgrad/Kokoro-82M), Apache-2.0 | Snapshot fixado em `f3ff3571791e39611d31c381e3a41a3af07b4987`; SHA-256 do modelo e voz registrados nos logs. A proveniência dos dados de treinamento da voz não ficou plenamente resolvida; uso restrito à qualificação local, sem redistribuição do áudio/modelo. |
| Kokoro G2P / eSpeak NG | [Licença do `espeakng-loader`](https://github.com/thewh1teagle/espeakng-loader/blob/main/LICENSE) (MIT) e [licença upstream do eSpeak NG](https://github.com/espeak-ng/espeak-ng), GPL-3.0-or-later | O pacote Python não declara licença nos metadados; a fonte publica MIT para o wrapper e inclui eSpeak NG (biblioteca/dados) sob GPL. Uso local de avaliação; nenhum desses binários será redistribuído. Uma futura distribuição deve revisar obrigações GPL e empacotamento com especialista. |
| Faster Whisper | [Repositório oficial](https://github.com/SYSTRAN/faster-whisper), MIT | `tiny.en` local fixado em `0d3d19a32d3338f10357c0889762bd8d64bbdeba`; hash do modelo nos logs; CPU/int8. |
| PyAV | [Versões oficiais](https://pypi.org/project/av/18.1.1/) | `av==18.1.1`; o 19.0.2 incompatível foi detectado e substituído antes do aceite. |
| FFmpeg | [Aviso legal oficial](https://ffmpeg.org/legal.html) | Build preexistente com `--enable-gpl` e libx264: uso local apenas; não redistribuir esse binário. |
| SQLite | [Copyright oficial](https://www.sqlite.org/copyright.html) | Código SQLite em domínio público; biblioteca da stdlib Python. |
| ImageGen | [Documentação da API](https://developers.openai.com/learn/imagegen) não comprova, por si, direito de uso sem custo adicional da conta | Não chamado. O fallback de importação PNG sintético foi criado localmente e importado no render Remotion. Nenhuma API/trial foi iniciado. |
| GitHub Actions e Socket | [Billing oficial do GitHub](https://docs.github.com/en/actions/concepts/billing-and-usage), [runners públicos](https://docs.github.com/en/actions/reference/runners/github-hosted-runners) e [preços oficiais Socket](https://socket.dev/pricing) | `docs-validation` usa `ubuntu-latest`, gratuito em repo público. Os checks Socket preexistentes `Project Report` e `Pull Request Alerts` passaram; a página oficial lista Free por US$0 e repositórios públicos ilimitados. O workflow GitHub não invoca Socket; não foi alterado plano, cobrança ou integração. |

O `package-lock.json` e o freeze Python fixam versões; inventários de metadados de licença estão em `qualification/logs/`. O scan encontrou 242 pacotes npm instalados: zero sem metadado, 11 referências Remotion com `LICENSE.md` presente e 49 entradas opcionais de plataformas não Windows ausentes da instalação. O inventário Python contém 101 distribuições; a única sem campo de licença, `espeakng-loader==0.2.4`, foi verificada na fonte: wrapper MIT e eSpeak NG empacotado GPL-3.0-or-later. Esses inventários refletem metadados e fontes publicados, e não substituem parecer jurídico.

## Custo e dados

- Não houve chamada a API paga, teste de API com crédito, imagem gerada por serviço, assinatura adicional, runner privado ou compra.
- Downloads vieram de registries/repositórios oficiais e foram armazenados no ambiente local isolado.
- A PR recebeu os checks Socket já instalados no repositório. A tabela oficial lista plano Free de US$0 e repositórios públicos ilimitados; o FAQ informa que o app lê manifests/lockfiles. Nenhum plano/configuração de cobrança foi alterado; saldo de uso mensal da conta não foi consultado.
- `HF_HUB_DISABLE_TELEMETRY=1`; dependências de áudio em CPU; sem CUDA.
- Evidências públicas guardam hashes, versões, metadados e transcrição sintética, sem modelos pesados, vídeo, áudio gerado, credenciais, tokens ou caminho pessoal.
- O npm bloqueou o script de instalação do `esbuild`; o bundle foi verificado com `transformSync` e o Remotion render real passou. Não se habilitou script de terceiro.

## Compatibilidade corrigida

O `faster-whisper==1.2.1` falhou com PyAV 19.0.2 porque a API `av.open(..., metadata_errors=...)` foi removida. A remoção consta nas [notas oficiais do PyAV](https://github.com/PyAV-Org/PyAV/releases); a [issue do Faster Whisper](https://github.com/SYSTRAN/faster-whisper/issues/1589) registra o mesmo conflito e a compatibilidade com PyAV abaixo de 19. O ambiente foi fixado em PyAV 18.1.1, a instalação foi validada com `pip check`, e as repetições de transcrição passaram com timestamps.

## Rollback

Todas as dependências instaladas nesta WO são isoladas e podem ser removidas apagando o runtime local. O único binário de sistema utilizado, FFmpeg/ffprobe, era preexistente e não foi modificado. A contribuição Git é reversível ao fechar a PR e reverter o commit; não há migração de dados nem mudança persistente no sistema.
