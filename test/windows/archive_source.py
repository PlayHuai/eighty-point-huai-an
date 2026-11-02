"""Archive git-selected worktree files, preserving Unicode paths on Windows."""
import io
import pathlib
import sys
import tarfile

root = pathlib.Path.cwd()
paths = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8").splitlines()
with tarfile.open(sys.argv[1], "w:gz") as archive:
    for path in paths:
        source = root / path
        if source.suffix == ".sh":
            data = source.read_bytes().replace(b"\r\n", b"\n")
            info = archive.gettarinfo(str(source), arcname=path)
            info.size = len(data)
            archive.addfile(info, io.BytesIO(data))
        else:
            archive.add(source, arcname=path, recursive=False)
