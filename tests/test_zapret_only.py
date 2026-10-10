"""Static regression checks for the Zapret-only Windows build.

These checks don't launch winws.exe or require administrator privileges.
"""

import ast
import re
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def source(path):
    return (ROOT / path).read_text(encoding="utf-8")


def assignment_dict_keys(path, varname):
    tree = ast.parse(source(path), filename=path)
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == varname
            for target in node.targets
        ):
            if isinstance(node.value, ast.Dict):
                return [key.value for key in node.value.keys]
    raise AssertionError(f"{varname} dict not found in {path}")


def process_method(name):
    tree = ast.parse(source("src/Backend/process.py"))
    process_class = next(
        node for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == "Process"
    )
    return next(
        node for node in process_class.body
        if isinstance(node, ast.FunctionDef) and node.name == name
    )


def assigns_zapret_to_engine(method):
    return any(
        isinstance(node, ast.Assign)
        and any(
            isinstance(target, ast.Attribute)
            and isinstance(target.value, ast.Name)
            and target.value.id == "self"
            and target.attr == "engine"
            for target in node.targets
        )
        and isinstance(node.value, ast.Constant)
        and node.value.value == "zapret"
        for node in ast.walk(method)
    )


class ZapretOnlyTests(unittest.TestCase):
    def test_zapret_is_only_registered_engine(self):
        self.assertEqual(assignment_dict_keys("src/_data.py", "DIRECTORIES"), ["zapret"])
        self.assertEqual(assignment_dict_keys("src/_data.py", "COMPONENTS_URLS"), ["zapret"])

    def test_saved_engine_and_launch_are_zapret(self):
        self.assertTrue(assigns_zapret_to_engine(process_method("__init__")))
        self.assertTrue(assigns_zapret_to_engine(process_method("start_process")))
        change = process_method("change_engine")
        self.assertTrue(
            any(isinstance(node, ast.If) and
                any(isinstance(child, ast.Return) for child in node.body)
                for node in ast.walk(change)),
            "change_engine must reject other engine requests",
        )
        self.assertIn("engine.lower() != 'zapret'", source("src/Backend/process.py"))

    def test_zapret_binary_and_driver_are_present(self):
        for name in ("winws.exe", "WinDivert.dll", "WinDivert64.sys"):
            with self.subTest(file=name):
                self.assertTrue((ROOT / "data/zapret" / name).is_file())

    def test_navigation_has_no_proxy_page(self):
        nav = source("src/res/qml/screen/MainScreen.qml")
        self.assertIn('"/zapret": resolvedUrl(', nav)
        self.assertNotIn('"/proxy":', nav)
        self.assertNotIn("target:proxyHelper", nav)

    def test_goodcheck_only_offers_zapret(self):
        page = source("src/res/qml/page/T_AdditionalUtilsPage.qml")
        self.assertIn("model: zapret_model", page)
        self.assertNotIn("goodbyeDPI_model", page)
        self.assertNotIn("engine.currentIndex", page)
        self.assertNotIn('page_router.go("/proxy")', page)
        self.assertNotIn("proxyBtn", page)

    def test_no_proxifyre_component_controls(self):
        page = source("src/res/qml/page/T_SystemComponentsPage.qml")
        self.assertNotIn("ProxiFyre", page)
        self.assertNotIn("proxyHelper", page)

    def test_qt_resource_paths_exist(self):
        resource = ROOT / "src/resource.qrc"
        tree = ET.parse(resource)
        files = [element.text for element in tree.iter("file")]
        self.assertGreater(len(files), 0)
        for path in files:
            with self.subTest(resource=path):
                self.assertTrue((resource.parent / path).is_file())

    def test_default_configuration_uses_zapret(self):
        config = source("data/settings/settings.ini")
        self.assertRegex(config, r"(?m)^engine\s*=\s*zapret\s*$")
        self.assertRegex(config, r"(?m)^zapret\s*=\s*True\s*$")


if __name__ == "__main__":
    unittest.main()
