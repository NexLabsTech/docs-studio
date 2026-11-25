# Correções durante a qualificação

## faster-whisper / PyAV

`faster-whisper==1.2.1` falhou com `av==19.0.2`: o caminho `av.open(..., metadata_errors=...)` tentava usar um argumento removido pelo PyAV 19. As [notas oficiais do PyAV](https://github.com/PyAV-Org/PyAV/releases) confirmam a remoção; a [issue do Faster Whisper #1589](https://github.com/SYSTRAN/faster-whisper/issues/1589) registra a incompatibilidade. Fixei `av==18.1.1`, versão não yanked; `pip check` passou e três smokes offline de transcrição passaram.

## Isolamento PowerShell

O primeiro harness de Python alterava `TEMP`/`TMP` no processo PowerShell chamador. Ao repetir a execução, o segundo filho passou a procurar o venv dentro de um `TEMP` aninhado e falhou ao iniciar. O harness foi corrigido para definir cache/temp apenas em `ProcessStartInfo.EnvironmentVariables` do filho. SQLite, TTS e ASR foram então repetidos com sucesso; as variáveis do shell chamador deixaram de mudar.

## Reprodutibilidade TTS

Antes de fixar o gerador, o mesmo texto/voz produziu hashes WAV diferentes. O smoke agora usa seed PyTorch 42 e `torch.use_deterministic_algorithms(True)`. Três repetições offline produziram o mesmo SHA-256 `E1AC799B20BFE51A27C078247E1453AC2FA7EB7434F2707EE7795ABBF6CA3286`.

## Remotion e scripts npm

O plugin Remotion não estava disponível na sessão; usei a CLI oficial com pacotes e browser isolados. O npm não aprovou o script opcional de instalação `esbuild@0.28.1`; nenhum script foi habilitado. `esbuild.transformSync` e três renders reais pela CLI passaram.

Nenhuma correção alterou código de produto, instalou componentes globalmente ou liberou acesso pago. As execuções finais de Kokoro e Faster Whisper usaram snapshots em cache, hashes fixos e modo offline.
