# Evidence Bundle — NDS-CORE-WO-001/CD-01

**Idioma:** português brasileiro. **Data:** 25/11/2026. **Estado:** correções submetidas para auditoria independente; não aprova nem promove checkpoint.

## Identificação e fonte

- Repositório: `NexLabsTech/docs-studio`; branch: `nds/core-wo-001`; PR draft #11: [NDS-CORE-WO-001](https://github.com/NexLabsTech/docs-studio/pull/11).
- Base confirmada: `main` = `c2bb0211adaf953c12f75d18be343be03cce7e93`, merge da PR #10. PF-01 permanece APPROVED; não repetida.
- Head de origem/CD-01: `49097c6eac92709a53f82a5e4e117144c0a13c19`. Context Lock revalidado; veja `context-lock.md` e hashes SHA-256 da fonte.
- Escopo desta atualização: somente correções F01–F04 do comentário de auditoria #7174370671, preservando a arquitetura e evidências anteriores ainda válidas. Código de produto e arquivos canônicos não foram alterados.
- PR continua draft; o SHA final e CI real desse exato HEAD estão disponíveis na [aba Checks da PR](https://github.com/NexLabsTech/docs-studio/pull/11/checks). O resultado precisa corresponder ao HEAD atual; o run antigo `45696205047` em `40ddb1e` é histórico e não é aceitação do HEAD final.

## Context Lock e escopo

`context-lock.md` contém as impressões SHA-256 do checkpoint, decisões, escopo, requisitos, arquitetura, Work Order, governança, segurança, benchmark, prompt, AGENTS, workflow e ruleset na base canônica, além de nova leitura da fonte na branch/HEAD apontados acima e do comentário integral de auditoria. O clone estava limpo antes da implementação deste CD-01. Caminhos pessoais foram omitidos.

As alterações Git permanecem em `.gitignore` e `evidence/NDS-CORE-WO-001/`; nenhum produto, UI, episódio, WAV/MP4, modelo, credencial ou publicação foi incluído. Smokes usam pastas novas ignoradas pelo Git.

## Matriz AC01–AC10 atualizada

| AC | Estado | Evidência e limite |
|---|---|---|
| AC01 | PASS | Source Check e Context Lock fresco em `context-lock.md`; base `c2bb0211…` e branch/head de origem `49097c6e…`. Hashes dos arquivos críticos preservados. |
| AC02 | PASS | Inventário Windows, hardware/software e disponibilidade do modelo/esforço: `windows-inventory.md` e `qualification/logs/windows-inventory.json`; sem dados de conta/segredos. |
| AC03 | PASS | Remotion CLI oficial 4.0.547; licença exata qualificada para o uso individual declarado, sem custo; render novo de 10 s e ffprobe real/asserts em `cd01-remotion-probe-*.json`. |
| AC04 | PASS técnico; gate comercial delimitado | Kokoro en-US e Faster Whisper offline/CPU, hash da saída WAV igual ao hash da entrada ASR, frase e 7 timestamps validados. Proveniência de `af_heart` não comprovada; áudio Kokoro não aprovado para exploração comercial. Licença e candidata gratuita alternativa em `license-cost-security.md`. |
| AC05 | PASS | FFmpeg com `-n`, probe real e asserts de H.264/AAC/duração/dimensões; SQLite create/read/rollback/commit/reopen. Logs `cd01-ffmpeg-probe-*` e `cd01-python-smoke-*.json`. |
| AC06 | PASS | Nenhum entitlement ImageGen comprovado sem custo adicional; API não chamada. Fixture sintética PNG cobre importação. |
| AC07 | PASS com limite | `benchmarks.md` compara RAM pela mesma soma WMI; TTS foi maior que Remotion. Tempos, RAM, tamanhos e hashes do CD-01 documentados. Amostragem é medida observada; o valor FFmpeg com uma amostra é somente limite inferior. |
| AC08 | PASS com risco explicitado | Zero custo adicional, lockfiles, origem/integrity, scripts lifecycle desativados, isolamento/rollback e licenças em `license-cost-security.md`. Direitos comerciais da voz Kokoro permanecem bloqueados; alternativa apenas proposta, não adotada. |
| AC09 | GATE DINÂMICO | PR #11 draft, push e checks são consultáveis no link de Checks. Só considerar PASS quando o workflow real concluir no SHA final idêntico ao HEAD atual da PR; o status é lido após o push final. Sem merge, bypass ou promoção. |
| AC10 | EVIDÊNCIA COMPLETA; revisão pendente | Bundle pt-BR, findings F01–F04, logs, benchmarks e Checkpoint Delta proposto. Risco legal MEDIUM Kokoro é explícito; auditor independente ainda deve decidir APPROVED/CORRECTION REQUIRED/BLOCKED. |

## F01–F04 e validações

- **F01 — PASS:** paths confinados a sandboxes aleatórios novos; sem traversal, absolute/drive/UNC/reparse/symlink ou destinos existentes. SQLite exclusivo, FFmpeg `-n`, Remotion sem overwrite. Processo filho tem ambiente sanitizado/allowlist e timeout com encerramento da árvore. Testes negativos cobrem sentinel externo e destino existente, ambos sem mudança; veja `cd01-negative-paths-*.json` e `cd01-process-tests-*.json`.
- **F02 — RESOLVIDO PARA CD-01, gate comercial da voz preservado:** Remotion individual é gratuito também para criação comercial pela versão 4.0.547. Para Kokoro, Apache-2.0 do peso não estabelece direitos de `af_heart`; não autorizamos uso comercial dessa voz. `tts_models/en/ljspeech/vits` foi proposto como alternativa local gratuita com pesos Apache-2.0 e corpus declarado em domínio público, mas não instalado/adotado; direitos/compatibilidade precisam ser reavaliados antes de substituição.
- **F03 — PASS:** ffprobe real em saídas Remotion/FFmpeg e asserts; hash TTS-ASR idêntico (`E1AC799B…`), frase correta, timestamps monotônicos/dentro de 2,775 s. Métrica RAM comparada e conclusão anterior corrigida: CD-01 TTS 1.415.843.840 > Remotion 1.212.628.992 bytes.
- **F04 — PASS:** `requirements-lock.txt` dry-run/offline, `pip check`, freeze; `npm ci --dry-run` com lifecycle scripts desativados, lock SHA/integrities verificadas e `npm ls`; versões instaladas comparadas aos pins. Nenhum download, reinstall, instalação global ou cache redundante.

## Execuções principais CD-01

- `test-negative-outputs.ps1` e `test-process-isolation.ps1` — PASS; traversal, absolute, UNC, junction, alvos existentes, sentinel, não herança de variável privada, parent env inalterado, timeout e kill da árvore.
- `run-python-smoke.ps1` — PASS, 61,166 s, timeout 300 s, offline por snapshots locais; TTS 21,211 s, ASR 4,224 s, SQLite 0,031256 s; pico WMI 1.415.843.840 B. Hash de WAV emitido/consumido idêntico; 7 timestamps dentro do áudio.
- `render-remotion.ps1` — PASS, 82,300 s, timeout 300 s, pico 1.212.628.992 B; ffprobe: H.264 1920×1080, 30 fps, 300/300 frames, 10,000 s.
- `ffmpeg-smoke.ps1` — PASS, 1,588 s, timeout 60 s; ffprobe: H.264 1280×720/30 fps + AAC 48 kHz mono, 5,000 s. WMI capturou uma amostra; não chamar de pico máximo.
- `install-python.ps1` — PASS, exit `[0,0,0]`, pins/freeze compatíveis, zero reinstalação.
- `install-remotion.ps1` — PASS, exit `[0,0]`, 291 pacotes remotos com integrity, zero origem fora do npm oficial, versões diretas batem com pins, `npm ci` foi somente dry-run.
- Logs CD-01 em `qualification/logs/CD-01/`; tabela e hashes em `benchmarks.md`. `qualification/.runtime/` ignorado pelo Git.

## Segurança, custo, erros e gate

- Custo adicional: **US$ 0**. Sem APIs pagas, compras, créditos, instalação global, bypass, publicação ou alteração de cobrança.
- Contexto de cada subprocesso é limpo; variáveis adicionais seguem allowlist. O teste prova segredo sentinel do pai não herdado e TEMP/TMP/USERPROFILE/APPDATA do chamador inalterados.
- ImageGen não foi chamado. FFmpeg GPL e eSpeak NG GPL não serão redistribuídos sem revisão das obrigações. H.264/patentes permanecem fora do uso local qualificado.
- Kokoro `af_heart`: questão de licença/proveniência comercial MEDIUM, gate explícito, sem substituir arquitetura unilateralmente. Coqui VITS LJSpeech é somente candidato sem instalação/aceite.
- `git diff --check`, validação documental, testes afetados, push e CI exato ainda serão reportados na PR. CI em SHA antigo não vale como CI do HEAD final.

## Checkpoint Delta e decisão

`checkpoint-delta-proposed.md` é proposta, não aplicada. Não modificar `docs/12-checkpoint.md`; não promover checkpoint, não fazer merge, não implementar produto, não iniciar NDS-MEDIA-WO-002 e não publicar vídeos. Pare para auditoria independente.
