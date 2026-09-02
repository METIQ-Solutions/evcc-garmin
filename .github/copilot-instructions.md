# Copilot Instructions — evccg (Garmin Connect IQ app for evcc)

Repository-specific guidance for working with the evcc-garmin codebase.

## Architecture: why the JQ filter exists

* This repo is a Garmin Connect IQ watch app that talks to an evcc energy
  management server via its REST API.
* Garmin Connect IQ has strict limits around incoming JSON/API response size
  and device memory, and some watch modes (glance/tiny glance) are very
  memory-constrained. The server-side JQ filter is therefore **not merely an
  optimization**: it reduces the evcc state to the fields the watch needs and
  performs server-side aggregation (e.g. the grid price forecast) instead of
  sending large raw datasets such as full forecast time series.
* Consequence: do not casually replace server-side aggregation with sending a
  large raw dataset to the watch. If an API data format changes, prefer keeping
  aggregation server-side; if moving work to the device is considered, first
  validate Garmin response-size/memory implications and inspect how the existing
  parser/model handles the data.

## JQ source and generated filter

* Readable JQ source: `source/jq/state.jq` — edit this file.
* Generated (minified) variant embedded in the app: `source/jq/minified.mc`
  (stores the filter in the `EVCC_JQ_FILTER` Monkey C global).
* Generator: `scripts/generate-jq/` (`generate-jq.bat` → `generate-jq.js`,
  Windows Script Host / JScript).
* `minified.mc` **must never be hand-edited or hand-optimized**; it is generated.
* To regenerate after changing `state.jq`, run the generator **from the
  `scripts/generate-jq` directory** (the script uses a relative path
  `..\\..\\source\\jq\\state.jq`):

  * `cd scripts/generate-jq; .\generate-jq.bat`
  * or use the VS Code task `evccg: Generate JQ`
    (`cd .\scripts\generate-jq;.\generate-jq.bat`).
* If minification can be improved, improve `generate-jq.js` itself so all future
  runs reproduce the result — do not touch only the generated output.

## Generator behavior and pitfalls

* The minifier strips a UTF-8 BOM, removes full-line `#` comments, then removes
  whitespace in a jq-token-aware way:

  * keeps a separator between two word characters (prevents `def avg` fusing
    into the identifier `defavg`);
  * keeps a separator between a lone `.` and a following word character only
    when the source had a space (keeps `.battery.soc` glued, keeps `. as $x`
    distinct);
  * preserves whitespace and backslash escapes inside single/double-quoted
    strings.
* If you change the minifier, keep those guarantees intact and re-verify by
  regenerating and testing the JQ (see below). Do not regress to a naive
  "drop all whitespace" minifier — it breaks `def`/`. as` tokenization.

## Testing a JQ filter against a real evcc server

> Security rule: do NOT persist any concrete evcc test server hostname, URL, IP
> address, or test endpoint in repository files. When live testing is needed,
> ask the operator which evcc server to use for the current task/session; use it
> only for that session once supplied.

Repeatable workflow for validating a filter against a live evcc server:

1. Obtain the current raw response first: `GET /api/state` (unfiltered).
2. Inspect its actual structure (top-level keys, `forecast` shape, whether a
   `result` wrapper is present, timestamp/format of forecast entries) before
   assuming anything about the API.
3. Extract the exact JQ filter to test (read `source/jq/state.jq`, or extract
   and unescape the `EVCC_JQ_FILTER` string from `source/jq/minified.mc` to test
   exactly what the app sends).
4. URL-encode the filter and send it as the `jq` query parameter:
   `GET /api/state?jq=<url-encoded-filter>`.
5. Check the HTTP status, then parse and inspect the returned JSON.
6. Verify expected fields and, where relevant, the aggregated/calculated values
   (e.g. grid price forecast averages/periods) against the raw data.
7. Measure sizes where relevant:

   * the decoded JQ filter length in bytes,
   * the filtered response size (compare to the raw response size).
8. Be aware that evcc may impose transport constraints (e.g. a limit on the JQ
   query length on `/api/state`). Verify the actual limit/behavior against the
   targeted evcc version rather than hard-coding assumptions. Distinguish a JQ
   parse/data-format problem from a transport/query-size rejection (the latter
   typically returns an error before the filter is evaluated).

## Compatibility and API changes

* evcc's `/api/state` structure can change between versions. Before adapting the
  JQ:

  * inspect the actual current response first;
  * identify whether the existing `state.jq` contains compatibility handling for
    old and new formats (e.g. a `.result` root wrapper, object vs array forecast
    entries, RFC3339 vs Unix timestamps);
  * preserve that compatibility unless the task explicitly permits removing it;
  * reproduce failures against a real server **before** redesigning application
    code.
* Do not conflate a data-format/parsing issue with a transport constraint
  (query-size limit). Confirm which one you are hitting before changing code.

## Generated files and application (Monkey C) code

* Changes to derived files (e.g. `minified.mc`) originate from the formatted
  source (`state.jq`) or the generator — never edit generated files directly.
* Garmin Monkey C files live under `source/main` (data layer in
  `source/main/data/state/model`, web request in
  `source/main/data/state/web-request`). The app parses JSON via `JsonAdapter`
  and has models such as `EvccState`, `GridPriceForecast`, `SolarForecast`,
  `Loadpoint`.
* Some JSON sections are handled as optional by the existing parser/model code:
  the parser checks for their presence (e.g. `getJsonObjectOrNull`) and simply
  does not render that part of the UI when they are absent. Before introducing
  application-code changes for missing API data, inspect the existing
  parser/model behavior first. Do not generalize: verify per-field how the app
  handles absence before touching Monkey C.

## Validation workflow

* Review `git status` before and after changes; distinguish generated files from
  source files.
* Preserve unrelated pre-existing working-tree modifications; do not fold them
  into unrelated work.
* Regenerate derived files (minified JQ, drawables) rather than editing them.
* After relevant changes, verify the Garmin project still builds/type-checks
  (e.g. no compile/type errors across `source/main`).
* Do not commit unless the task explicitly asks for a commit.
