#!/usr/bin/env python3
"""
Syncthing 配置文件修改工具

用法:
    python3 update-config.py <json 文件路径> <xml 文件路径> <syncthing 路径>
"""

import json
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def update_xml_element(parent, key, value):
    """递归更新 XML 元素"""
    if key in parent.attrib and not isinstance(value, dict):
        parent.set(key, str(value).lower() if isinstance(value, bool) else str(value))
    elif isinstance(value, dict):
        element = parent.find(key)
        if element is None:
            element = ET.SubElement(parent, key)
        for sub_key, sub_value in value.items():
            update_xml_element(element, sub_key, sub_value)
    elif isinstance(value, bool):
        element = parent.find(key)
        if element is None:
            element = ET.SubElement(parent, key)
        element.text = str(value).lower()
    elif isinstance(value, (int, float)):
        element = parent.find(key)
        if element is None:
            element = ET.SubElement(parent, key)
        element.text = str(value)
    elif isinstance(value, str):
        element = parent.find(key)
        if element is None:
            element = ET.SubElement(parent, key)
        element.text = value
    elif value is None:
        element = parent.find(key)
        if element is not None:
            element.text = ""


def update_config(config_path, updates):
    """更新 Syncthing 配置文件"""
    tree = ET.parse(config_path)
    root = tree.getroot()

    for section, values in updates.items():
        section_element = root.find(section)
        if section_element is None:
            section_element = ET.SubElement(root, section)

        if isinstance(values, dict):
            for key, value in values.items():
                update_xml_element(section_element, key, value)

    tree.write(config_path, encoding="utf-8", xml_declaration=True)


def main():
    json_path = Path(sys.argv[1])
    with open(json_path, encoding="utf-8") as f:
        updates = json.load(f)

    config_path = Path(sys.argv[2])
    if not config_path.exists():
        # 缺失配置但已有状态时拒绝生成，避免重置身份或丢失文件夹配置。
        if any(config_path.parent.iterdir()):
            raise FileNotFoundError(f"Refusing to regenerate missing {config_path}: existing state")
        subprocess.run(
            [sys.argv[3], "generate", "--home", str(config_path.parent), "--no-port-probing"],
            check=True,
        )

    update_config(config_path, updates)


if __name__ == "__main__":
    main()
