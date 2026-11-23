"""Static regressions for the 2026 Spanish Home and low-end GPU profiles.

The full C++ build runs separately in GitHub Actions.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


def read_config(name):
    text = (ROOT / "data" / name).read_text(encoding="utf-8")
    return dict(re.findall(r'^"([^"]+)"\\s+"([^"]+)"$', text, re.M))


class Interface2026RegressionTests(unittest.TestCase):
    def test_home_compiles_without_legacy_splice(self):
        code = (ROOT / "src/menu/mainmenu.cpp").read_text(encoding="utf-8")
        self.assertIn("MainMenuPage::MainMenuPage(", code)
        self.assertIn("MainMenuPage::~MainMenuPage()", code)
        self.assertIn("JUGAR PARTIDO", code)
        self.assertIn("CONFIGURACIÓN", code)
        self.assertNotIn("GetMenuTas//", code)

    def test_widescreen_not_forced_to_five_by_four(self):
        main = (ROOT / "src/main.cpp").read_text(encoding="utf-8")
        self.assertNotIn("new MenuTask(5.0f / 4.0f", main)
        self.assertIn('GetInt("context_x", 1280)', main)

    def test_all_fps_profiles_use_unlimited_graphics_scheduler(self):
        for fname, fps in [
            ("lenovo_110_15ibr.config", "30"),
            ("lenovo_60fps.config", "60"),
            ("lenovo_120fps_experimental.config", "120"),
        ]:
            with self.subTest(fname=fname):
                cfg = read_config(fname)
                self.assertEqual(cfg.get("graphics3d_frametime_ms"), "0")
                self.assertEqual(cfg.get("graphics_fps_limit"), fps)
                self.assertEqual(cfg.get("graphics_vsync"), "false")

    def test_exp_120_has_lower_render_cost(self):
        config = read_config("lenovo_120fps_experimental.config")
        self.assertEqual(config["context_x"], "800")
        self.assertEqual(config["context_y"], "450")
        self.assertEqual(config["graphics_ssao_samples"], "4")

    def test_tv_scoreboard_displays_live(self):
        code = (ROOT / "src/menu/ingame/scoreboard.cpp").read_text(encoding="utf-8")
        self.assertIn('"EN VIVO"', code)
        self.assertIn("SetGoalCount(0, 0)", code)
        self.assertIn("SetGoalCount(1, 0)", code)


if __name__ == "__main__":
    unittest.main()
