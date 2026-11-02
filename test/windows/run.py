"""Windows entry point for the bounded real-environment test runner."""
import argparse
import pathlib
import subprocess


def main():
    parser = argparse.ArgumentParser(
        description="Run Windows / Ubuntu integration tests. Later rounds retry "
        "non-PASS cases from the previous round's results.tsv."
    )
    parser.add_argument("--max", type=int, default=2, dest="maximum",
                        help="Maximum round index, inclusive (default: 2).")
    parser.add_argument("--start-index", type=int, default=1,
                        help="First round to execute; retries round M-1 if M>1.")
    parser.add_argument("--output", type=pathlib.Path,
                        default=pathlib.Path(r"D:\huai_an_80\auto_test"),
                        help="Output directory; created when absent.")
    args = parser.parse_args()
    if not 1 <= args.start_index <= args.maximum <= 100:
        parser.error("Require 1 <= --start-index <= --max <= 100.")
    script = pathlib.Path(__file__).with_name("Run.ps1")
    return subprocess.call([
        "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass",
        "-File", str(script), "-MaxTurn", str(args.maximum),
        "-StartRound", str(args.start_index),
        "-OutputDirectory", str(args.output.resolve()),
    ])


if __name__ == "__main__":
    raise SystemExit(main())
