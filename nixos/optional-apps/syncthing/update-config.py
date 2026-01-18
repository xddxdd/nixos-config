#!/usr/bin/env python3
"""
Syncthing 配置文件修改工具

用法:
    python3 update-syncthing-config.py <json 文件路径> <xml 文件路径>
    python3 update-syncthing-config.py updates.json /var/lib/syncthing/config.xml
"""

import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def update_xml_element(parent, key, value):
    """递归更新 XML 元素"""
    if isinstance(value, dict):
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
    update_config(config_path, updates)


if __name__ == "__main__":
    main()
