# Inventário Windows — NDS-CORE-WO-001

Inventário local para qualificação, coletado em 25/11/2026. Identificadores da máquina, usuário e caminhos pessoais foram omitidos.

| Item | Resultado |
|---|---|
| Sistema | Windows 11 Home Single Language, 64-bit, versão 10.0.26200, build 26200 |
| CPU | AMD Ryzen 5 2500U, 4 núcleos / 8 processadores lógicos, até 2,0 GHz |
| RAM | 22,90 GiB instalada |
| GPU | Radeon Vega 8 (1 GiB) e Radeon 535 Series (2 GiB); também aparece adaptador virtual Parsec. Nenhuma NVIDIA disponível. |
| Armazenamento C: | 222,45 GiB totais; 34,01 GiB livres antes das instalações e 30,98 GiB ao encerrar a qualificação. |
| Python | CPython 3.12.10 x64; runtime e pacotes em ambiente virtual isolado |
| Node.js / npm | Node 26.4.0; npm 11.17.0; pacotes Remotion no diretório de qualificação, sem instalação global |
| Remotion | 4.0.547 (`@remotion/cli`, `remotion`); renderização pela CLI oficial, pois o plugin não estava disponível nesta sessão |
| Áudio/ASR | Kokoro 0.9.4; PyTorch 2.15.0+cpu; faster-whisper 1.2.1; PyAV 18.1.1; inferência CPU/int8 |
| FFmpeg / ffprobe | Gyan full build 9.0.2; build habilita GPL e libx264; já estava instalado antes desta WO |
| SQLite | Biblioteca da stdlib Python, SQLite 3.49.1; CLI `sqlite3` ausente. `node:sqlite` disponível no Node 26, mas em estado Release Candidate, por isso não foi escolhido. |
| Git / GitHub CLI | Git 2.55.0.windows.3; `gh` autenticado no contexto da organização NexLabsTech |
| Codex | CLI 0.172.0; configuração local lida sem alteração: `gpt-6-luna`, esforço `max` |

O ambiente não tem CUDA. Kokoro, Faster Whisper e o render Remotion foram executados em CPU; nenhum runtime GPU foi instalado.

## Isolamento e mudanças no host

Python, cache de modelos, cache npm, arquivos de saída e temporários ficaram em diretórios locais isolados. Não houve `pip`/`npm` global, instalação administrativa, alteração de `PATH`, instalação de driver, serviço ou configuração de sistema. FFmpeg/ffprobe eram preexistentes. Os caminhos absolutos foram removidos dos artefatos públicos.
