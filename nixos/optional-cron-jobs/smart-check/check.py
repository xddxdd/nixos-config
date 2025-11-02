#!/usr/bin/env python
import glob
import json
import os
import subprocess
import sys


def run_command(command):
    try:
        # Ignore return code as they might be for old failures
        result = subprocess.run(command, capture_output=True, text=True)
        return result.stdout
    except FileNotFoundError:
        print(
            f"Command not found: {command[0]}. Please ensure smartctl is installed and in your PATH."
        )
        return None


def check_sata_drive(device_path):
    print(f"Checking SATA drive: {device_path}")
    output = run_command(["smartctl", "-a", device_path, "--json"])
    if output:
        try:
            data = json.loads(output)
            if not data.get("smart_status", {}).get("passed"):
                print(f"  SMART status FAILED for {device_path}")
                return False

            attributes = data.get("ata_smart_attributes", {}).get("table", [])
            reallocated_sector_count = 0
            uncorrectable_error_count = 0

            for attr in attributes:
                if attr.get("name") == "Reallocated_Sector_Ct":
                    reallocated_sector_count = attr.get("raw", {}).get("value", 0)
                elif attr.get("name") == "Uncorrectable_Error_Cnt":
                    uncorrectable_error_count = attr.get("raw", {}).get("value", 0)

            if reallocated_sector_count > 0:
                print(
                    f"  WARNING: {device_path} has Reallocated_Sector_Ct: {reallocated_sector_count}"
                )
                return False
            if uncorrectable_error_count > 0:
                print(
                    f"  WARNING: {device_path} has Uncorrectable_Error_Cnt: {uncorrectable_error_count}"
                )
                return False

            print(f"  SATA drive {device_path} SMART status OK.")
            return True

        except json.JSONDecodeError:
            print(
                f"  Error: Could not decode JSON from smartctl output for {device_path}"
            )
            return False
    return False


def check_nvme_drive(device_path):
    print(f"Checking NVMe drive: {device_path}")
    output = run_command(["smartctl", "-a", device_path, "--json"])
    if output:
        try:
            data = json.loads(output)
            nvme_health_info = data.get("nvme_smart_health_information_log", {})

            critical_warning = nvme_health_info.get("critical_warning", 0)
            media_errors = nvme_health_info.get("media_errors", 0)

            if critical_warning > 0:
                print(
                    f"  WARNING: {device_path} has Critical Warning: {critical_warning}"
                )
                return False
            if media_errors > 0:
                print(f"  WARNING: {device_path} has Media Errors: {media_errors}")
                return False

            print(f"  NVMe drive {device_path} SMART status OK.")
            return True

        except json.JSONDecodeError:
            print(
                f"  Error: Could not decode JSON from smartctl output for {device_path}"
            )
            return False
    return False


def find_and_check_drives():
    all_passed = True

    skipped_devices = os.environ.get("SKIPPED_DEVICES", "").split(",")

    # Find SATA drives using glob
    sata_devices = glob.glob("/dev/sd[a-z]")

    for device in sata_devices:
        if device in skipped_devices:
            continue
        # Further check if smartctl supports the device
        if run_command(["smartctl", "-i", device]):
            if not check_sata_drive(device):
                all_passed = False

    # Find NVMe drives using glob
    nvme_devices = glob.glob("/dev/nvme[0-9]n[0-9]")

    for device in nvme_devices:
        if device in skipped_devices:
            continue
        # Further check if smartctl supports the device
        if run_command(["smartctl", "-i", device]):
            if not check_nvme_drive(device):
                all_passed = False

    if all_passed:
        print("All SMART checks passed.")
        sys.exit(0)
    else:
        print("Some SMART checks failed or showed warnings.")
        sys.exit(1)


if __name__ == "__main__":
    find_and_check_drives()
