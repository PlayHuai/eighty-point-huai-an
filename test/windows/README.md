# Windows / Ubuntu integration automation

Only the Windows Flutter client and the isolated Ubuntu deployment are targeted.
The catalogue is [case.list](case.list). `READY` means implemented, **not passed**.
`TODO` chat cases are excluded. A missing result is never a PASS.

## Run

From the repository root in an interactive Windows desktop session:

```powershell
python .\test\windows\run.py --max 4 --start-index 3 --output D:\huai_an_80\auto_test
python .\test\windows\run.py --help
```

`--max N` is the maximum round **index**, inclusive, not a count of extra rounds.
`--start-index M` starts at round M. For M > 1, the runner reads
`<output>\第{M-1}轮\results.tsv`, selects FAIL/BLOCKED/NOT_RUN (all non-PASS,
non-TODO entries), and copies their issue descriptions into `need_test.list`.
It does not rerun previous PASS cases. A missing previous report is an error,
not an implicit full-suite run. With M=1, an existing selection is preserved;
otherwise all non-chat catalogue cases initialize the selection.
`--output dir` creates the directory if absent; quote paths containing spaces.
Existing round results are never overwritten. Require `1 <= M <= N <= 100`.
The entry point propagates PowerShell's exit status: zero for no remaining
issues, nonzero for failures or invalid arguments. A single invocation executes
one round and emits the repair handoff; further rounds require repaired code and
a subsequent invocation. There is no hidden unattended repair process.

Equivalent direct PowerShell invocation:

```powershell
.\test\windows\Run.ps1 -MaxTurn 4 -StartRound 3 -OutputDirectory D:\huai_an_80\auto_test
```

To rerun failures **plus** the new v3 cases in rounds 2–3:

```powershell
.\test\windows\Run.ps1 -MaxTurn 3 -StartRound 2 -OutputDirectory D:\huai_an_80\auto_test\full_run_20261103 -IncludeCaseIds TABLE-001,TABLE-002,TABLE-003,TABLE-004,TABLE-005,TABLE-006,TABLE-007,TABLE-008
```

`IncludeCaseIds` applies to retry rounds, merges with failures, and allows reruns
even when the preceding round passed. TABLE-006 waits a real five minutes;
normal rooms test the real ready barrier and ten-second fallback. Explicit rare-rule
fixtures enter the requested phase directly, only in the `autotest` build.
Screenshots of changed screens/dialogs are retained in `<output>\ui`.
Each round also keeps its own copies in `<output>\第{N}轮\ui`, so later
screenshots cannot replace earlier visual evidence.

Default output: `D:\huai_an_80\auto_test`. The first run creates `need_test.list`
from every non-chat case. It accepts a case ID followed by its description, so
reviewers may narrow it. Preserve case IDs when replacing descriptions with issue
text. Each round retains `issues\<title>-<id>\issue.txt`, optional `page.png`,
`passed_case.txt`, `results.tsv`, deployment/build/integration logs.
`case_report.txt` lists per-round counts and fixes verified by a later PASS.

The client uses **API_ENDPOINT**, not `END_ENDPOINT`:

* `API_ENDPOINT=http://192.168.117.129:8081` (native gRPC, no TLS in this test LAN)
* `WEBSOCKET_ENDPOINT=ws://192.168.117.129:8080/events`

Both defines are supplied to ordinary Windows builds and integration builds.
HTTP health and gRPC socket preflights run before testing, and ENV cases verify
real gRPC authentication and a real WebSocket event. No local fake server is used.
The test session store is isolated in memory to avoid replacing the developer's
Windows secure-storage credentials; cross-process secure-storage persistence is
not covered by the automatic-login case.
Widget gestures and text entry are automated. The integration binding registers
Flutter's test text-input channel to avoid native Windows IME races when editing
the same focused field repeatedly; native hardware-keyboard/IME behavior itself
is not covered. UI navigation waits for route transitions before the next action.

Helpers wait for authoritative single-card dealing to finish and for delayed
robots to return control, rather than expecting immediate completion in an RPC.
Default dealing takes 20 seconds per hand; robot moves take 2–4 seconds.
The full practice-match case has a 120-minute wall-clock limit (other cases:
30 minutes), and the native driver has a four-hour overall limit. These remain
bounded real-time tests; no game clock is accelerated or rule assertion skipped.

## Deployment safety

`Deploy.ps1` archives git-selected current worktree files (including uncommitted
changes, excluding ignored secrets/builds), uploads by SCP, and rebuilds only
Compose project `huai-auto-test` at `/home/derek/auto_test`.
The generated remote `deploy/.env` retains database credentials between rounds;
no volumes or other projects are deleted. Ports 8080/8081 must be free.
The Ubuntu Dockerfile receives the requested Aliyun GOPROXY after `WORKDIR /src`.
Docker must be able to pull MySQL 8.4, Redis 7-alpine and Go 1.25-alpine. An HTTP
mirror homepage responding does not prove that these images exist.
On the first successful download, MySQL and Redis receive project-local tags
`huai-auto-test/mysql:cached` and `huai-auto-test/redis:cached`. Later rounds use
these exact local images with `pull_policy: never`; a missing cache is populated
from an existing local upstream image or downloaded once. Go's builder image is
also pulled only when missing, and builds use `--pull=false`. Image IDs are
recorded remotely in `test/windows/cached-images.txt`. Docker retains these
images across container rebuilds and host restarts; manually pruning images can
remove the cache. Upgrading dependencies is an explicit maintenance operation,
not part of each test round. No database or Redis volume is removed.
Python 3 on Windows handles archives containing Unicode design/document names.

Runner argument/output regression tests:

```powershell
Push-Location .\test\windows
python -m unittest -v test_run
Pop-Location
```

Password failures are tracked transactionally in MySQL: five wrong attempts
lock the account for 15 minutes, including correct-password requests during
the lock. A successful login after expiry resets the counter.
Friend-request UUID receipts follow the existing room-service cache convention:
authenticated caller plus UUID plus target, successful requests only, maximum
10,000 receipts. They do not survive a service restart or cache eviction; this
is not a claim of durable cross-restart idempotency.

Live game actions retain ordered public metadata for reconnect and paginated
`ListEventsAfter` replay (default 100, maximum 1,000 per page). Replay contains no
hidden cards or proofs; the personalized snapshot supplies the current state.
The live session and its replay are still in memory and disappear when the
session is deleted or the server restarts. Reconnect returns at most 1,000
missed events; use `ListEventsAfter` pagination for a longer backlog.

## Deterministic game fixtures

Test image uses [Dockerfile.autotest](Dockerfile.autotest), Go build tag
`autotest` **and** runtime `HUAI_AUTOTEST=1`. A room-start gRPC metadata field
`x-huai-test-scenario` selects a server-defined named fixture. Ordinary builds
reject this field, and do not compile the fixture constructor at all.
Fixtures replace initial cards / late-hand state only; actions, ownership,
versions, privacy, scoring and phase transitions still use the real server.
Never deploy this image as a production service or expose its ports publicly.

Late-hand fixtures do not pretend to demonstrate an entire 2-to-A match, and
settlement assertions must check durable player statistics separately from the
in-memory phase. Unsupported requirements must remain visible as failures or
explicitly incomplete cases, not be downgraded into passing assertions.

## Copilot repair loop

At round completion or an environment failure, the runner collects every issue,
replaces `need_test.list` with their full descriptions (preserving IDs), and writes
`repair-prompt.txt`. The current Copilot session can review and fix these issues,
commit verified fixes referring to local issue paths, then run:

```powershell
.\test\windows\Run.ps1 -StartRound 2 -MaxTurn 2
```

The external Copilot CLI is not installed in the current environment (the
`copilot` executable is only an unavailable shim). Therefore the scripts provide
an explicit session handoff rather than claiming an unattended repair agent ran.
Never start a round with `StartRound > MaxTurn`; never overwrite an existing
round's results. Existing issues disappear from the report only after a later
real PASS. No-error rounds stop. Further autonomous process integration requires
an installed, authenticated Copilot CLI with scoped tool permissions.

## Known incomplete coverage

The latest evidence, root-cause assessment and remaining cases are written to
`<output>\case_report.txt`. A passed hand or a `finished` snapshot alone does not
prove settlement: tests additionally inspect all four balances/statistics and
retries, disconnect progression and structured settlement/history UI.
The isolated autotest build funds the spring and A-level score fixture players
with 1,000 points before play; ordinary accounts still start at zero. Funding
is compiled out of production and requires `HUAI_AUTOTEST=1`. Zero-balance loss
caps and conservation also have repository regression tests.
The catalogue has 77 implemented cases, including all formerly blocked
non-game cases, plus two deliberately deferred chat TODO cases. Actual PASS
counts always come from the report, not this implementation count.

Fresh full run, followed by its authorized failure-only repair round:

```powershell
python .\test\windows\run.py --max 2 --start-index 1 --output D:\huai_an_80\auto_test\full_run_20261102
python .\test\windows\run.py --max 2 --start-index 2 --output D:\huai_an_80\auto_test\full_run_20261102
```

If that limit is reached with failures, stop and obtain approval before raising
`--max`; an extension is never implicit.

## UI reference screenshots

The complete page/dialog/menu inventory is `ui.list`. Every report writes
`<output>\ui-coverage.tsv` with CAPTURED/MISSING and absolute screenshot paths.
Missing screenshots are explicit review gaps, never silently counted as covered.
The dual-client case mounts two real ClientApp instances side-by-side, each with
its own authenticated provider scope, channel, session cache, Navigator and
WebSocket. It exercises presence, logout/relogin and invitation acceptance
without requiring a second Windows machine.

The catalogue includes four real one-human/three-server-bot practice-room cases:
UI entry/exit, creation idempotency/isolation, action retry/version/reconnect,
and an entire match with continuation. Ordinary and practice sessions use the
same production action validation; practice tests also inspect the isolated
database for absence of game sessions/ledger and unchanged user statistics.
Boundary/disabled-account setup uses passwordless SSH to the dedicated Compose
database and accepts only IDs created by that case. No fixture RPC is exposed.

Each round also visits real login, registration, lobby, room-creation, friend
list/profile, waiting-room screens and support/join-by-ID dialogs independently
of the retry selection.
Game scenarios capture the table, spring settlement and history dialog.
Screenshots are stored under `<output>\ui` with Chinese feature names, one
current PNG per feature; `screenshots.tsv` records capture time/path. Later
captures replace the same feature image, while per-round failure screenshots
remain immutable. Capture errors are recorded in `ui\capture-error.txt`, not
substituted with a mock image. Transient snackbars are dismissed for reference
captures; failure screenshots are not altered. Chat pages are captured for design
reference only: chat functional cases remain TODO. The walkthrough follows
the table's room-chat entry and seeds one real private message to expose its
message-action menu; this is not full sending/receiving functional coverage.
The dealer's lighter PNG is copied unchanged from
`ui-design/asserts/ic_lighter/lighter.png` into the client asset bundle.

To refresh these reference screens without deploying or executing another case
round, run from the repository root (the existing selection must be valid):

```powershell
Push-Location .\client
flutter drive -d windows --driver=test_driver\windows_driver.dart --target=integration_test\windows_real_test.dart `
  --dart-define=API_ENDPOINT=http://192.168.117.129:8081 `
  --dart-define=WEBSOCKET_ENDPOINT=ws://192.168.117.129:8080/events `
  --dart-define=AUTO_TEST_CATALOG=D:\huai_an_80\eighty-point-huai-an\test\windows\case.list `
  --dart-define=AUTO_TEST_SELECTION=D:\huai_an_80\auto_test\need_test.list `
  --dart-define=AUTO_TEST_ROUND=D:\huai_an_80\auto_test\ui\capture-session `
  --dart-define=AUTO_TEST_UI=D:\huai_an_80\auto_test\ui `
  --dart-define=AUTO_TEST_UI_ONLY=true
Pop-Location
```

Screenshot-only mode does not write catalogue results or clear previous failures.
Settlement/history references are captured by their game cases, not this walkthrough.
After a normal run the Flutter binding's final framework failures are reconciled
with per-case statuses, preserving pre-reconciliation files as
`results.before-framework.tsv` / `passed_case.before-framework.txt`. This prevents
late image/layout errors from being incorrectly counted as a passing case.
