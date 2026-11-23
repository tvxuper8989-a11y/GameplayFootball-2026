#!/usr/bin/env python3
"""Prepara un pack SQLite de temporada sin modificar la base original.

Sin CSV, la copia conserva los planteles historicos: NO es una temporada
2026/27 actualizada. Los CSV deben incluir datos comprobados.
"""
import argparse
import csv
import math
import sqlite3
import tempfile
from pathlib import Path

FIELDS = {
    "teams": {"name", "shortname", "league_id", "logo_url", "kit_url", "color1", "color2"},
    "players": {"firstname", "lastname", "role", "base_stat", "age", "skincolor",
                "hairstyle", "haircolor", "height"},
}
INTEGER = {"league_id", "age", "skincolor"}
DECIMAL = {"base_stat", "height"}
CONFIG = '''"context_x" "1280"
"context_y" "720"
"context_fullscreen" "false"
"graphics3d_frametime_ms" "33"
"physics_frametime_ms" "10"
"database_filename" "databases/default/database_2026.sqlite"
'''


def rows_from_csv(db, table, path):
    if not path:
        return []
    columns = {r[1] for r in db.execute('PRAGMA table_info("' + table + '")')}
    with Path(path).open(encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        headers = reader.fieldnames
        if not headers or "id" not in headers or len(headers) != len(set(headers)):
            raise ValueError(f"{path}: encabezado invalido")
        if (set(headers) - FIELDS[table] - {"id"}) or (set(headers) - columns):
            raise ValueError(f"{path}: columnas inexistentes o no permitidas")
        ids, parsed = set(), []
        for line, row in enumerate(reader, start=2):
            if None in row or any(not isinstance(v, str) for v in row.values()):
                raise ValueError(f"{path}:{line}: numero incorrecto de columnas")
            if all(not v.strip() for v in row.values()):
                continue
            raw_id = row["id"].strip()
            if not raw_id.isdecimal() or int(raw_id) < 1:
                raise ValueError(f"{path}:{line}: id invalido")
            id_ = int(raw_id)
            if id_ in ids:
                raise ValueError(f"{path}:{line}: id repetido")
            ids.add(id_)
            if not db.execute(f'SELECT 1 FROM "{table}" WHERE id=?', (id_,)).fetchone():
                raise ValueError(f"{path}:{line}: {table} id={id_} no existe")
            values = {}
            for col in headers:
                if col == "id" or not row[col].strip():
                    continue
                value = row[col].strip()
                if col in INTEGER:
                    value = int(value)
                    if value < 0 or (col == "age" and not 14 <= value <= 60):
                        raise ValueError(f"{path}:{line}: valor entero invalido {col}")
                elif col in DECIMAL:
                    value = float(value)
                    if not math.isfinite(value) or (col == "base_stat" and not 0 <= value <= 1) or (col == "height" and not 1 <= value <= 2.5):
                        raise ValueError(f"{path}:{line}: valor decimal invalido {col}")
                values[col] = value
            if values:
                parsed.append((id_, values))
        return parsed


def prepare(root: Path, teams=None, players=None, apply=False):
    root = Path(root)
    source = root / "data/databases/default/database.sqlite"
    target = root / "data/databases/default/database_2026.sqlite"
    cfg = root / "data/football_2026.config"
    if not source.is_file():
        raise ValueError(f"No existe {source}")
    if target.exists() or cfg.exists():
        raise ValueError("La temporada ya existe; por seguridad no se sobrescribe.")
    with sqlite3.connect(source.resolve().as_uri() + "?mode=ro", uri=True) as old:
        tables = {r[0] for r in old.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        if not {"teams", "players", "leagues"}.issubset(tables):
            raise ValueError("La BD original no tiene las tablas principales")
        edits = {table: rows_from_csv(old, table, csv_file)
                 for table, csv_file in (("teams", teams), ("players", players))}
        print("Cambios:", len(edits["teams"]), "equipos y", len(edits["players"]), "jugadores")
        if not teams and not players:
            print("ATENCION: esta copia sigue teniendo los planteles originales.")
        if not apply:
            print("SIMULACION: usar --apply para crear el pack.")
            return
        with tempfile.NamedTemporaryFile(dir=target.parent, prefix=".temporada-",
                                         suffix=".sqlite", delete=False) as tmp:
            temp = Path(tmp.name)
        try:
            with sqlite3.connect(temp) as new:
                old.backup(new)
                with new:
                    for table, changes in edits.items():
                        for id_, values in changes:
                            keys = sorted(values)
                            setters = ", ".join(f'"{key}"=?' for key in keys)
                            new.execute(f'UPDATE "{table}" SET {setters} WHERE id=?',
                                        [values[key] for key in keys] + [id_])
                if new.execute("PRAGMA integrity_check").fetchone()[0] != "ok":
                    raise ValueError("Fallo la integridad del pack SQLite")
            temp.replace(target)
            try:
                with cfg.open("x", encoding="utf-8") as output:
                    output.write(CONFIG)
            except Exception:
                target.unlink(missing_ok=True)
                raise
        finally:
            temp.unlink(missing_ok=True)
    print("Pack creado:", target)
    print("Configuracion creada:", cfg)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=Path("."))
    p.add_argument("--teams", type=Path)
    p.add_argument("--players", type=Path)
    p.add_argument("--apply", action="store_true")
    a = p.parse_args()
    try:
        prepare(a.root, a.teams, a.players, a.apply)
    except (ValueError, OSError, sqlite3.Error) as exc:
        p.error(str(exc))


if __name__ == "__main__":
    main()
