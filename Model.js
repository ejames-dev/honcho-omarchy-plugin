// Pure parsing for bin/omarchy-honcho's output. No process or network
// access here, so this loads fine in both Quickshell and an offline test
// runner.
function clean(value, max) {
  var s = String(value === undefined || value === null ? "" : value)
  s = s.replace(/[<>]/g, "").replace(/[\x00-\x1f\x7f]/g, "")
  var cap = max || 128
  return s.length > cap ? s.slice(0, cap) : s
}

// `raw` is bin/omarchy-honcho's stdout: one or more JSON lines followed by
// a final line holding the queried base URL.
function parseStatus(raw) {
  var lines = String(raw || "").split("\n").filter(function(l) { return l.trim() !== "" })
  if (lines.length === 0) return emptyStatus()

  var url = clean(lines[lines.length - 1], 200)
  var jsonText = lines.slice(0, -1).join("\n")

  var data
  try { data = JSON.parse(jsonText) } catch (e) { data = null }

  var reachable = !!data && typeof data === "object" && data.status === "ok"
  return { reachable: reachable, url: url || "http://localhost:8000" }
}

function emptyStatus() {
  return { reachable: false, url: "" }
}

function pillText(status) {
  return status && status.reachable ? "Honcho" : "Honcho · off"
}

function tooltipText(status) {
  if (!status) return "Checking Honcho…"
  return status.reachable
    ? "Honcho is reachable at " + status.url
    : "Honcho is not reachable at " + (status.url || "the configured URL")
}

if (typeof module !== "undefined") {
  module.exports = {
    clean: clean,
    parseStatus: parseStatus,
    emptyStatus: emptyStatus,
    pillText: pillText,
    tooltipText: tooltipText
  }
}
