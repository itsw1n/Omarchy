#!/usr/bin/env python3
"""Exercise installation/rollback in isolated homes, never the live desktop."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('setup', ROOT / 'scripts/setup.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='omarchy setup test ')
        self.home = Path(self.temp.name) / 'another-user'
        self.config = self.home / '.config'

    def tearDown(self):
        self.temp.cleanup()

    def install(self, *args, success=True):
        result = subprocess.run([str(ROOT / 'install.sh'), '--home', str(self.home), *args],
                                cwd='/', text=True, capture_output=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        return result

    def test_dry_run_writes_nothing(self):
        self.install('--dry-run')
        self.assertFalse(self.home.exists())

    def test_fresh_install_bundles_spectra_and_portable_monitors(self):
        self.install()
        shell = json.loads((self.config / 'omarchy/shell.json').read_text())
        self.assertEqual(shell['bar']['id'], 'itsw1n.spectra-bar')
        plugin = self.config / 'omarchy/plugins/itsw1n.spectra-bar'
        self.assertEqual((plugin / 'Bar.qml').read_bytes(),
                         (ROOT / 'dotfiles/omarchy/plugins/itsw1n.spectra-bar/Bar.qml').read_bytes())
        self.assertEqual((self.config / 'hypr/monitors.lua').read_bytes(),
                         (ROOT / 'profiles/portable-monitors.lua').read_bytes())
        self.assertFalse(any(p.is_symlink() for p in self.config.rglob('*')))
        self.assertFalse((self.config / 'waybar').exists())
        self.assertFalse((self.config / 'omarchy/hooks/post-boot.d/20-deymn-v4-configs').exists())

    def test_repeat_install_preserves_unrelated_settings_and_monitor(self):
        self.install()
        monitor = self.config / 'hypr/monitors.lua'
        monitor.write_text('-- other machine\n')
        unrelated = self.config / 'omarchy/plugins/my-plugin'
        unrelated.mkdir()
        (unrelated / 'keep').write_text('keep')
        self.install()
        self.assertEqual(monitor.read_text(), '-- other machine\n')
        self.assertEqual((unrelated / 'keep').read_text(), 'keep')
        self.install('--monitors', 'deymn')
        self.assertEqual(monitor.read_bytes(), (ROOT / 'profiles/deymn-monitors.lua').read_bytes())

    def test_restore_recovers_original_and_absence(self):
        (self.config / 'hypr').mkdir(parents=True)
        (self.config / 'hypr/monitors.lua').write_text('original')
        self.install()
        saved = next((self.home / '.local/state/omarchy-setup/backups').iterdir())
        self.install('--restore', str(saved))
        self.assertEqual((self.config / 'hypr/monitors.lua').read_text(), 'original')
        self.assertFalse((self.config / 'omarchy').exists())
        self.assertEqual(len(list((self.home / '.local/state/omarchy-setup/backups').iterdir())), 2)

    def test_repository_directory_and_nested_hook_links_are_detached(self):
        source = Path(self.temp.name) / 'source config'
        source.mkdir()
        (source / 'monitors.lua').write_text('original monitor')
        (source / 'bindings.lua').write_text('original bindings')
        self.config.mkdir(parents=True)
        (self.config / 'hypr').symlink_to(source)
        hooks = self.config / 'omarchy/hooks'
        hooks.mkdir(parents=True)
        linked = Path(self.temp.name) / 'theme hooks'
        linked.mkdir()
        (linked / '10-deymn-branding').write_text('obsolete')
        (hooks / 'theme-set.d').symlink_to(linked)
        self.install()
        self.assertFalse((self.config / 'hypr').is_symlink())
        self.assertFalse((hooks / 'theme-set.d').is_symlink())
        self.assertEqual((source / 'bindings.lua').read_text(), 'original bindings')
        self.assertTrue((linked / '10-deymn-branding').exists())
        self.assertFalse((hooks / 'theme-set.d/10-deymn-branding').exists())

    def test_copy_failure_rolls_back(self):
        (self.config / 'hypr').mkdir(parents=True)
        original = self.config / 'hypr/monitors.lua'
        original.write_text('original')
        real_copy = shutil.copy2

        def failing_copy(src, dst, *args, **kwargs):
            if str(dst).endswith('omarchy/shell.json') and str(dst).startswith(str(self.config)):
                raise OSError('injected full disk')
            return real_copy(src, dst, *args, **kwargs)

        with mock.patch('sys.argv', ['setup.py', '--home', str(self.home)]), \
             mock.patch.object(setup.shutil, 'copy2', side_effect=failing_copy):
            with self.assertRaisesRegex(OSError, 'injected full disk'):
                setup.main()
        self.assertEqual(original.read_text(), 'original')
        self.assertFalse((self.config / 'omarchy').exists())


if __name__ == '__main__':
    unittest.main()
