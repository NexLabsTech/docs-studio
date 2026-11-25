import argparse
import ctypes
import hashlib
import json
import os
import sqlite3
import struct
import sys
import time
import wave
import zlib
from pathlib import Path
from ctypes import wintypes


TEXT = "Hello, this is a local audio test."
VOICE = "af_heart"
KOKORO_REPO = "hexgrad/Kokoro-82M"
KOKORO_REVISION = "f3ff3571791e39611d31c381e3a41a3af07b4987"
KOKORO_MODEL_FILE = "kokoro-v1_0.pth"
WHISPER_MODEL = "Systran/faster-whisper-tiny.en"
WHISPER_REVISION = "0d3d19a32d3338f10357c0889762bd8d64bbdeba"
RANDOM_SEED = 42


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def peak_working_set_bytes():
    if os.name != "nt":
        return None

    class Counters(ctypes.Structure):
        _fields_ = [
            ("cb", wintypes.DWORD),
            ("PageFaultCount", wintypes.DWORD),
            ("PeakWorkingSetSize", ctypes.c_size_t),
            ("WorkingSetSize", ctypes.c_size_t),
            ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPagedPoolUsage", ctypes.c_size_t),
            ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
            ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
            ("PagefileUsage", ctypes.c_size_t),
            ("PeakPagefileUsage", ctypes.c_size_t),
        ]

    kernel32 = ctypes.WinDLL("kernel32.dll", use_last_error=True)
    kernel32.GetCurrentProcess.restype = wintypes.HANDLE
    psapi = ctypes.WinDLL("Psapi.dll", use_last_error=True)
    get_memory_info = psapi.GetProcessMemoryInfo
    get_memory_info.argtypes = [wintypes.HANDLE, ctypes.POINTER(Counters), wintypes.DWORD]
    get_memory_info.restype = wintypes.BOOL
    counters = Counters()
    counters.cb = ctypes.sizeof(counters)
    ok = get_memory_info(kernel32.GetCurrentProcess(), ctypes.byref(counters), counters.cb)
    return int(counters.PeakWorkingSetSize) if ok else None


def run_tts(output):
    import numpy as np
    import torch
    from huggingface_hub import snapshot_download
    from kokoro import KPipeline
    from kokoro.model import KModel

    if torch.cuda.is_available():
        raise RuntimeError("CPU-only test unexpectedly detected CUDA")
    torch.manual_seed(RANDOM_SEED)
    torch.use_deterministic_algorithms(True)
    start = time.perf_counter()
    snapshot_start = time.perf_counter()
    snapshot = Path(snapshot_download(
        repo_id=KOKORO_REPO,
        revision=KOKORO_REVISION,
        allow_patterns=["config.json", KOKORO_MODEL_FILE, f"voices/{VOICE}.pt"],
        cache_dir=str(Path(os.environ["HF_HOME"]) / "hub"),
    ))
    snapshot_elapsed = time.perf_counter() - snapshot_start
    setup_start = time.perf_counter()
    model = KModel(
        repo_id=KOKORO_REPO,
        config=str(snapshot / "config.json"),
        model=str(snapshot / KOKORO_MODEL_FILE),
    )
    pipeline = KPipeline(lang_code="a", repo_id=KOKORO_REPO, model=model, device="cpu")
    pipeline.voices[VOICE] = torch.load(snapshot / "voices" / f"{VOICE}.pt", weights_only=True)
    setup_elapsed = time.perf_counter() - setup_start
    synthesis_start = time.perf_counter()
    chunks = [audio for _, _, audio in pipeline(TEXT, voice=VOICE)]
    synthesis_elapsed = time.perf_counter() - synthesis_start
    if not chunks:
        raise RuntimeError("Kokoro returned no audio chunks")
    samples = np.concatenate(chunks)
    pcm = (np.clip(samples, -1.0, 1.0) * 32767).astype("<i2")
    output.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(output), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(24000)
        wav.writeframes(pcm.tobytes())
    elapsed = time.perf_counter() - start
    return {
        "mode": "kokoro-en-us",
        "text": TEXT,
        "voice": VOICE,
        "language": "en-US (Kokoro lang_code='a')",
        "model_revision": KOKORO_REVISION,
        "offline_mode": os.environ.get("HF_HUB_OFFLINE") == "1",
        "model_sha256": sha256(snapshot / KOKORO_MODEL_FILE),
        "voice_sha256": sha256(snapshot / "voices" / f"{VOICE}.pt"),
        "device": "cpu",
        "random_seed": RANDOM_SEED,
        "deterministic_algorithms": True,
        "snapshot_download_elapsed_s": round(snapshot_elapsed, 3),
        "model_setup_elapsed_s": round(setup_elapsed, 3),
        "synthesis_elapsed_s": round(synthesis_elapsed, 3),
        "torch_version": torch.__version__,
        "duration_s": round(len(pcm) / 24000, 3),
        "elapsed_s": round(elapsed, 3),
        "peak_working_set_bytes": peak_working_set_bytes(),
        "output_bytes": output.stat().st_size,
        "output_sha256": sha256(output),
    }


def run_whisper(input_path):
    from huggingface_hub import snapshot_download
    from faster_whisper import WhisperModel

    start = time.perf_counter()
    snapshot_start = time.perf_counter()
    snapshot = Path(snapshot_download(
        repo_id=WHISPER_MODEL,
        revision=WHISPER_REVISION,
        allow_patterns=["config.json", "model.bin", "tokenizer.json", "vocabulary.txt"],
        cache_dir=str(Path(os.environ["HF_HOME"]) / "hub"),
    ))
    snapshot_elapsed = time.perf_counter() - snapshot_start
    setup_start = time.perf_counter()
    model = WhisperModel(
        str(snapshot), device="cpu", compute_type="int8", cpu_threads=4, num_workers=1
    )
    setup_elapsed = time.perf_counter() - setup_start
    inference_start = time.perf_counter()
    segments, info = model.transcribe(
        str(input_path),
        language="en",
        beam_size=1,
        word_timestamps=True,
        vad_filter=False,
    )
    words = []
    last_start = -1.0
    last_end = -1.0
    for segment in segments:
        for word in segment.words or []:
            start_s = float(word.start)
            end_s = float(word.end)
            if start_s < last_start or end_s < last_end or end_s < start_s:
                raise RuntimeError("word timestamps are not monotonic")
            last_start = start_s
            last_end = end_s
            words.append({
                "word": word.word.strip(),
                "start_s": round(start_s, 3),
                "end_s": round(end_s, 3),
                "probability": round(float(word.probability), 3),
            })
    inference_elapsed = time.perf_counter() - inference_start
    if not words:
        raise RuntimeError("Faster Whisper returned no word timestamps")
    elapsed = time.perf_counter() - start
    return {
        "mode": "faster-whisper-word-timestamps",
        "model": WHISPER_MODEL,
        "model_revision": WHISPER_REVISION,
        "offline_mode": os.environ.get("HF_HUB_OFFLINE") == "1",
        "model_sha256": sha256(snapshot / "model.bin"),
        "language": info.language,
        "device": "cpu",
        "compute_type": "int8",
        "elapsed_s": round(elapsed, 3),
        "snapshot_download_elapsed_s": round(snapshot_elapsed, 3),
        "model_setup_elapsed_s": round(setup_elapsed, 3),
        "inference_elapsed_s": round(inference_elapsed, 3),
        "peak_working_set_bytes": peak_working_set_bytes(),
        "text": " ".join(word["word"] for word in words),
        "word_timestamps": words,
    }


def run_sqlite(db_path):
    db_path.parent.mkdir(parents=True, exist_ok=True)
    if db_path.exists():
        db_path.unlink()
    start = time.perf_counter()
    db = sqlite3.connect(db_path, isolation_level=None)
    db.execute("CREATE TABLE qualification (id INTEGER PRIMARY KEY, value TEXT NOT NULL)")
    db.execute("BEGIN IMMEDIATE")
    db.execute("INSERT INTO qualification(value) VALUES (?)", ("rolled-back",))
    db.execute("ROLLBACK")
    db.execute("BEGIN IMMEDIATE")
    db.execute("INSERT INTO qualification(value) VALUES (?)", ("committed",))
    db.execute("COMMIT")
    before_close = db.execute("SELECT id, value FROM qualification").fetchall()
    db.close()
    reopened = sqlite3.connect(db_path)
    after_reopen = reopened.execute("SELECT id, value FROM qualification").fetchall()
    reopened.close()
    expected = [(1, "committed")]
    if before_close != expected or after_reopen != expected:
        raise RuntimeError("SQLite transaction or reopen check failed")
    return {
        "mode": "sqlite-create-read-transaction-reopen",
        "sqlite_version": sqlite3.sqlite_version,
        "rows_before_close": before_close,
        "rows_after_reopen": after_reopen,
        "elapsed_s": round(time.perf_counter() - start, 6),
        "peak_working_set_bytes": peak_working_set_bytes(),
        "database_bytes": db_path.stat().st_size,
        "database_sha256": sha256(db_path),
    }


def png_chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


def make_png(output):
    width = height = 96
    rows = []
    for y in range(height):
        row = bytearray([0])
        for x in range(width):
            row.extend(((x * 255) // (width - 1), (y * 255) // (height - 1), 160))
        rows.append(bytes(row))
    raw = b"".join(rows)
    payload = bytearray(b"\x89PNG\r\n\x1a\n")
    payload.extend(png_chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)))
    payload.extend(png_chunk(b"IDAT", zlib.compress(raw, level=9)))
    payload.extend(png_chunk(b"IEND", b""))
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(payload)
    return {
        "mode": "synthetic-image-import-fixture",
        "format": "PNG",
        "width": width,
        "height": height,
        "output_bytes": output.stat().st_size,
        "output_sha256": sha256(output),
    }


def main():
    parser = argparse.ArgumentParser()
    subs = parser.add_subparsers(dest="mode", required=True)
    tts = subs.add_parser("tts")
    tts.add_argument("--output", type=Path, required=True)
    whisper = subs.add_parser("whisper")
    whisper.add_argument("--input", type=Path, required=True)
    sqlite = subs.add_parser("sqlite")
    sqlite.add_argument("--db", type=Path, required=True)
    image = subs.add_parser("image")
    image.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.mode == "tts":
        result = run_tts(args.output)
    elif args.mode == "whisper":
        result = run_whisper(args.input)
    elif args.mode == "sqlite":
        result = run_sqlite(args.db)
    else:
        result = make_png(args.output)
    print(json.dumps(result, ensure_ascii=False, sort_keys=True))


if __name__ == "__main__":
    main()
