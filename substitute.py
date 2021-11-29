#!/usr/bin/env python3

import os
from pathlib import Path
import sys
from typing import Union

VERSION_TOKEN = "${VERSION}$"
DATE_TOKEN = "${DATE}$"
LICENSE_TOKEN = "${LICENSE}$"
LICENSE_FILENAME_TOKEN = "${FILENAME}$"

SCRIPT_DIR = Path(__file__).parent

def replace_tokens(path: Union[str, Path]) -> None:
    with open(path, 'r', encoding='utf-8') as infile:
        text = infile.read()

    text = (
        text.replace(VERSION_TOKEN, os.environ['VERSION'])
            .replace(DATE_TOKEN, os.environ['DATE'])
            .replace(LICENSE_TOKEN, license_notice(Path(path).name))
    )

    with open(path, 'w', encoding='utf-8') as outfile:
        outfile.write(text)


def license_notice(name: str) -> str:
    with open(SCRIPT_DIR / 'license-notice.tpl', 'r', encoding='utf-8') as infile:
        return infile.read().replace(LICENSE_FILENAME_TOKEN, name)


def main() -> None:
    for path in sys.argv[1:]:
        replace_tokens(path)

if __name__ == '__main__':
    main()
