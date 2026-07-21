"""Archivo de log rotativo del server.

loader_app llama a attach_file_handler() al arrancar; el panel de admin lee
LOG_FILE para el visor de logs. Separado de loader_app para que la app admin
pueda importar la ruta sin ciclos.
"""
import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path

LOG_DIR = Path(__file__).resolve().parents[2] / "logs"
LOG_FILE = LOG_DIR / "server.log"


def attach_file_handler() -> None:
    """Suma un RotatingFileHandler (1 MB x 3) al root logger con el mismo
    formato que la consola. Idempotente: no duplica el handler en reloads."""
    root = logging.getLogger()
    for h in root.handlers:
        if isinstance(h, RotatingFileHandler) and h.baseFilename == str(LOG_FILE):
            return
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    handler = RotatingFileHandler(
        LOG_FILE, maxBytes=1_000_000, backupCount=3, encoding="utf-8"
    )
    handler.setFormatter(
        logging.Formatter("%(asctime)s %(levelname)-7s %(name)s: %(message)s")
    )
    root.addHandler(handler)


def tail_log(lines: int = 200) -> list[str]:
    """Últimas [lines] líneas del log actual (sin los archivos rotados)."""
    if not LOG_FILE.exists():
        return []
    text = LOG_FILE.read_text(encoding="utf-8", errors="replace")
    return text.splitlines()[-lines:]
