import argparse
import ctypes
import hashlib
import json
import os
import re
import sqlite3
import stat
import struct
import time
import wave
import zlib
from pathlib import Path

TEXT = "Hello, this is a local audio test."
EXPECTED_TEXT = "hello this is a local audio test"
VOICE = "af_heart"
KOKORO_REPO = "hexgrad/Kokoro-82M"
KOKORO_REVISION = "f3ff3571791e39611d31c381e3a41a3af07b4987"
KOKORO_MODEL_FILE = "kokoro-v1_0.pth"
WHISPER_MODEL = "Systran/faster-whisper-tiny.en"
WHISPER_REVISION = "0d3d19a32d3338f10357c0889762bd8d64bbdeba"
RANDOM_SEED = 42
REPARSE_ATTRIBUTE = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0x400)


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def is_reparse(path):
    try:
        info = Path(path).lstat()
    except FileNotFoundError:
        return False
    return Path(path).is_symlink() or bool(getattr(info, "st_file_attributes", 0) & REPARSE_ATTRIBUTE)


def assert_no_reparse(path):
    absolute = Path(os.path.abspath(path))
    current = Path(absolute.anchor)
    for part in absolute.parts[1:]:
        current = current / part
        if is_reparse(current):
            raise ValueError("Reparse point refused in qualification path")


def safe_output_path(sandbox, relative):
    root = Path(os.path.abspath(sandbox))
    assert_no_reparse(root)
    raw = os.fspath(relative)
    if not raw or "\x00" in raw or ":" in raw or raw.startswith(("\\\\", "//")):
        raise ValueError("Only a relative output path is accepted")
    candidate_path = Path(raw)
    if candidate_path.is_absolute() or candidate_path.drive:
        raise ValueError("Absolute output path refused")
    parts = re.split(r"[\\/]", raw)
    if any(part in ("", ".", "..") for part in parts):
        raise ValueError("Traversal or empty path component refused")
    candidate = Path(os.path.abspath(root.joinpath(*parts)))
    if os.path.commonpath((os.path.normcase(str(root)), os.path.normcase(str(candidate)))) != os.path.normcase(str(root)):
        raise ValueError("Output path escapes qualification sandbox")
    assert_no_reparse(candidate)
    try:
        candidate.lstat()
    except FileNotFoundError:
        return candidate
    raise FileExistsError("Existing output destination refused")


def qualification_sandbox():
    qualification_root = Path(__file__).resolve().parents[1]
    expected_parent = (qualification_root / ".runtime" / "runs").resolve()
    supplied = os.environ.get("NDS_QUALIFICATION_SANDBOX")
    if not supplied:
        raise RuntimeError("NDS_QUALIFICATION_SANDBOX is required")
    supplied_path = Path(os.path.abspath(supplied))
    assert_no_reparse(supplied_path)
    sandbox = supplied_path.resolve(strict=True)
    if os.path.normcase(str(supplied_path)) != os.path.normcase(str(sandbox)):
        raise RuntimeError("Sandbox path must not resolve through a symlink or reparse point")
    if sandbox.parent != expected_parent or not re.fullmatch(r"run-[a-z0-9-]{2,24}-[a-f0-9]{32}", sandbox.name):
        raise RuntimeError("Sandbox is not a fresh child of the qualification run directory")
    assert_no_reparse(sandbox)
    return sandbox


def open_new_output(sandbox, relative):
    path = safe_output_path(sandbox, relative)
    return path, open(path, "xb")


def cached_snapshot(repo_id, revision, required_files):
    cache = Path(os.environ["HF_HUB_CACHE"])
    folder = "models--" + repo_id.replace("/", "--")
    snapshot = cache / folder / "snapshots" / revision
    if not snapshot.is_dir() or is_reparse(snapshot):
        raise RuntimeError("Pinned model snapshot is unavailable in the local cache")
    for name in required_files:
        path = snapshot / name
        if not path.is_file():
            raise RuntimeError("Pinned model file is missing from the local cache")
    return snapshot


def run_tts(sandbox):
    import numpy as np
    import torch
    from kokoro import KPipeline
    from kokoro.model import KModel

    if torch.cuda.is_available():
        raise RuntimeError("CPU-only test unexpectedly detected CUDA")
    torch.manual_seed(RANDOM_SEED)
    torch.use_deterministic_algorithms(True)
    snapshot = cached_snapshot(KOKORO_REPO, KOKORO_REVISION, ["config.json", KOKORO_MODEL_FILE, f"voices/{VOICE}.pt"])
    start = time.perf_counter()
    model = KModel(repo_id=KOKORO_REPO, config=str(snapshot / "config.json"), model=str(snapshot / KOKORO_MODEL_FILE))
    pipeline = KPipeline(lang_code="a", repo_id=KOKORO_REPO, model=model, device="cpu")
    pipeline.voices[VOICE] = torch.load(snapshot / "voices" / f"{VOICE}.pt", weights_only=True)
    chunks = [audio for _, _, audio in pipeline(TEXT, voice=VOICE)]
    if not chunks:
        raise RuntimeError("Kokoro returned no audio chunks")
    samples = np.concatenate(chunks)
    pcm = (np.clip(samples, -1.0, 1.0) * 32767).astype("<i2")
    output, output_stream = open_new_output(sandbox, "tts.wav")
    try:
        with wave.open(output_stream, "wb") as wav:
            wav.setnchannels(1)
            wav.setsampwidth(2)
            wav.setframerate(24000)
            wav.writeframes(pcm.tobytes())
    finally:
        output_stream.close()
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
        "synthesis_elapsed_s": round(time.perf_counter() - start, 3),
        "duration_s": round(len(pcm) / 24000, 3),
        "output_bytes": output.stat().st_size,
        "output_sha256": sha256(output),
    }, output


def run_whisper(sandbox, input_path, audio_duration):
    from faster_whisper import WhisperModel

    snapshot = cached_snapshot(WHISPER_MODEL, WHISPER_REVISION, ["config.json", "model.bin", "tokenizer.json", "vocabulary.txt"])
    start = time.perf_counter()
    model = WhisperModel(str(snapshot), device="cpu", compute_type="int8", cpu_threads=4, num_workers=1)
    inference_start = time.perf_counter()
    segments, info = model.transcribe(str(input_path), language="en", beam_size=1, word_timestamps=True, vad_filter=False)
    words = []
    last_start = -1.0
    last_end = -1.0
    for segment in segments:
        for word in segment.words or []:
            start_s = float(word.start)
            end_s = float(word.end)
            if start_s < 0 or start_s < last_start or end_s < last_end or end_s < start_s or end_s > audio_duration + 0.05:
                raise RuntimeError("word timestamps are not monotonic or exceed input audio duration")
            last_start, last_end = start_s, end_s
            words.append({"word": word.word.strip(), "start_s": round(start_s, 3), "end_s": round(end_s, 3), "probability": round(float(word.probability), 3)})
    inference_elapsed = time.perf_counter() - inference_start
    if not words:
        raise RuntimeError("Faster Whisper returned no word timestamps")
    text = " ".join(word["word"] for word in words)
    normalized = " ".join(re.findall(r"[a-z0-9]+", text.lower()))
    if normalized != EXPECTED_TEXT:
        raise RuntimeError("Faster Whisper transcript did not match the synthetic phrase")
    return {
        "mode": "faster-whisper-word-timestamps",
        "model": WHISPER_MODEL,
        "model_revision": WHISPER_REVISION,
        "model_sha256": sha256(snapshot / "model.bin"),
        "offline_mode": os.environ.get("HF_HUB_OFFLINE") == "1",
        "language": info.language,
        "device": "cpu",
        "compute_type": "int8",
        "elapsed_s": round(time.perf_counter() - start, 3),
        "inference_elapsed_s": round(inference_elapsed, 3),
        "input_file": "tts.wav",
        "input_sha256": sha256(input_path),
        "input_duration_s": audio_duration,
        "text": text,
        "word_count": len(words),
        "word_timestamps": words,
        "timestamps_monotonic": True,
        "timestamps_within_audio": True,
        "expected_transcript_match": True,
    }


def png_chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


def make_png(sandbox):
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
    path, stream = open_new_output(sandbox, "fixture.png")
    with stream:
        stream.write(payload)
    return {"mode": "synthetic-image-import-fixture", "format": "PNG", "width": width, "height": height, "output_bytes": path.stat().st_size, "output_sha256": sha256(path)}


def run_sqlite(sandbox):
    path, stream = open_new_output(sandbox, "qualification.sqlite")
    stream.close()
    start = time.perf_counter()
    db = sqlite3.connect(path, isolation_level=None)
    try:
        db.execute("CREATE TABLE qualification (id INTEGER PRIMARY KEY, value TEXT NOT NULL)")
        db.execute("BEGIN IMMEDIATE")
        db.execute("INSERT INTO qualification(value) VALUES (?)", ("rolled-back",))
        db.execute("ROLLBACK")
        db.execute("BEGIN IMMEDIATE")
        db.execute("INSERT INTO qualification(value) VALUES (?)", ("committed",))
        db.execute("COMMIT")
        before_close = db.execute("SELECT id, value FROM qualification").fetchall()
    finally:
        db.close()
    reopened = sqlite3.connect(path)
    try:
        after_reopen = reopened.execute("SELECT id, value FROM qualification").fetchall()
    finally:
        reopened.close()
    expected = [(1, "committed")]
    if before_close != expected or after_reopen != expected:
        raise RuntimeError("SQLite transaction or reopen check failed")
    return {"mode": "sqlite-create-read-transaction-reopen", "sqlite_version": sqlite3.sqlite_version, "rows_before_close": before_close, "rows_after_reopen": after_reopen, "elapsed_s": round(time.perf_counter() - start, 6), "database_bytes": path.stat().st_size, "database_sha256": sha256(path)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["all"])
    parser.parse_args()
    sandbox = qualification_sandbox()
    fixture = make_png(sandbox)
    tts, wav_path = run_tts(sandbox)
    with wave.open(str(wav_path), "rb") as wav:
        audio_duration = wav.getnframes() / float(wav.getframerate())
    asr = run_whisper(sandbox, wav_path, audio_duration)
    if tts["output_sha256"] != asr["input_sha256"]:
        raise RuntimeError("TTS output hash does not match the exact ASR input hash")
    sqlite = run_sqlite(sandbox)
    print(json.dumps({"mode": "python-local-qualification", "offline_mode": os.environ.get("HF_HUB_OFFLINE") == "1", "fixture": fixture, "tts": tts, "asr": asr, "tts_asr_hash_chain_match": True, "sqlite": sqlite}, ensure_ascii=False, sort_keys=True))


if __name__ == "__main__":
    main()
