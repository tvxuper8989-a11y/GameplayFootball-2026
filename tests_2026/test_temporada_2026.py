import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from temporada_2026 import prepare


class TestTemporada(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        folder = self.root / "data/databases/default"
        folder.mkdir(parents=True)
        self.src = folder / "database.sqlite"
        with sqlite3.connect(self.src) as db:
            db.execute("CREATE TABLE leagues(id INTEGER PRIMARY KEY, name TEXT)")
            db.execute("CREATE TABLE teams(id INTEGER PRIMARY KEY, name TEXT, shortname TEXT, league_id INTEGER)")
            db.execute("CREATE TABLE players(id INTEGER PRIMARY KEY, firstname TEXT, base_stat REAL, team_id INTEGER, formationorder INTEGER)")
            db.execute("INSERT INTO leagues VALUES(1,'Original')")
            db.execute("INSERT INTO teams VALUES(1,'Equipo viejo','VIE',1)")
            db.execute("INSERT INTO teams VALUES(2,'Equipo destino','DES',1)")
            db.execute("INSERT INTO players VALUES(1,'Jugador viejo',0.5,1,10)")

    def tearDown(self):
        self.tmp.cleanup()

    def test_dry_run_copy_and_update(self):
        csv_file = self.root / "teams.csv"
        csv_file.write_text("id,name\n1,Equipo actualizado\n", encoding="utf-8")
        prepare(self.root, teams=csv_file)
        out = self.src.with_name("database_2026.sqlite")
        self.assertFalse(out.exists())
        prepare(self.root, teams=csv_file, apply=True)
        with sqlite3.connect(self.src) as db:
            self.assertEqual(db.execute("SELECT name FROM teams").fetchone()[0], "Equipo viejo")
        with sqlite3.connect(out) as db:
            self.assertEqual(db.execute("SELECT name FROM teams").fetchone()[0], "Equipo actualizado")
        self.assertIn('"database_filename"', (self.root/"data/football_2026.config").read_text())

    def test_does_not_overwrite(self):
        prepare(self.root, apply=True)
        with self.assertRaisesRegex(ValueError, "ya existe"):
            prepare(self.root, apply=True)

    def test_reject_missing_id(self):
        csv_file = self.root / "teams.csv"
        csv_file.write_text("id,name\n999,Fantasma\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "no existe"):
            prepare(self.root, teams=csv_file, apply=True)
        self.assertFalse(self.src.with_name("database_2026.sqlite").exists())

    def test_reject_nan(self):
        csv_file = self.root / "players.csv"
        csv_file.write_text("id,base_stat\n1,nan\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "decimal invalido"):
            prepare(self.root, players=csv_file, apply=True)


    def test_transferencia_valida(self):
        csv_file = self.root / "traspasos.csv"
        csv_file.write_text("id,team_id,formationorder\n1,2,12\n", encoding="utf-8")
        prepare(self.root, players=csv_file, apply=True)
        with sqlite3.connect(self.src) as db:
            self.assertEqual(db.execute("SELECT team_id FROM players").fetchone()[0], 1)
        with sqlite3.connect(self.src.with_name("database_2026.sqlite")) as db:
            self.assertEqual(db.execute("SELECT team_id,formationorder FROM players").fetchone(), (2, 12))

    def test_transferencia_equipo_inexistente(self):
        csv_file = self.root / "traspasos.csv"
        csv_file.write_text("id,team_id\n1,999\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "no existe"):
            prepare(self.root, players=csv_file, apply=True)

    def test_liga_inexistente(self):
        csv_file = self.root / "equipos.csv"
        csv_file.write_text("id,league_id\n1,999\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "no existe"):
            prepare(self.root, teams=csv_file, apply=True)

    def test_entero_invalido(self):
        csv_file = self.root / "traspasos.csv"
        csv_file.write_text("id,team_id\n1,x\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "entero invalido"):
            prepare(self.root, players=csv_file, apply=True)


if __name__ == "__main__":
    unittest.main()
