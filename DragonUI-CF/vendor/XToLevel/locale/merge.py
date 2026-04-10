#!/usr/bin/env python3
"""
merge.py – bundle all files in a directory and its subdirectories into a single text file.

Output format
-------------
[files]
 //path/to/first_file.ext
 <contents of first_file.ext>

 //path/to/another/second_file.ext
 <contents of second_file.ext>
"""

from pathlib import Path
import argparse
import sys

SCRIPT_PATH = Path(__file__).resolve()  # absolute path to this script


def merge_files(src_dir: Path, out_file: Path, encoding: str = "utf-8") -> None:
    """
    Merge all files inside `src_dir` (recursively) into `out_file`.

    • Skips directories.
    • Skips the output file itself.
    • Skips this script even if it lives in `src_dir`.
    """

    # Collect all files, ensuring deterministic alphabetical order
    all_files = sorted(
        f
        for f in src_dir.rglob("*")  # Recursively glob for all files
        if f.is_file() and f.resolve() not in {out_file.resolve(), SCRIPT_PATH}
    )

    if not all_files:
        sys.exit("No files found to merge.")

    with out_file.open("w", encoding=encoding, newline="\n") as merged:
        merged.write("[files]\n")

        for f in all_files:
            # Get path relative to the source directory, using forward slashes
            relative_path = f.relative_to(src_dir).as_posix()
            merged.write(f"\n//{relative_path}\n")
            try:
                merged.write(f.read_text(encoding=encoding))
            except UnicodeDecodeError:
                # Handle binary files that can't be read with text encoding
                print(
                    f"Warning: Could not decode '{relative_path}' as {encoding}. Omitting content.",
                    file=sys.stderr,
                )
                merged.write("<binary file, content not included>\n")
            except Exception as e:
                print(
                    f"Error reading file '{relative_path}': {e}",
                    file=sys.stderr
                )
                merged.write(f"<error reading file: {e}>\n")


    print(f"Merged {len(all_files)} file(s) → {out_file}")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Merge all files in a directory and its subdirectories into a single file."
    )
    parser.add_argument(
        "directory",
        nargs="?",
        type=Path,
        default=".",
        help="Directory containing files to merge (default: current directory)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default="merged.bundle.txt",
        help="Output file name (default: merged.bundle.txt)",
    )
    args = parser.parse_args()

    merge_files(args.directory.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()