import videojs from "video.js";

document.addEventListener("turbo:load", initOverlay);
document.addEventListener("DOMContentLoaded", initOverlay);

async function initOverlay() {
  const overlay = document.getElementById("tactic-overlay");
  if (!overlay) return;

  const videoId = overlay.dataset.videoId;
  const url = overlay.dataset.timelinesUrl;
  const videoEl = document.getElementById(`player-${videoId}`);
  if (!videoEl) return;

  // video.js のインスタンス取得（既に初期化済みならそれを使う）
  const player = (videoEl.player && videoEl.player.on) ? videoEl.player : (window.videojs ? videojs(videoEl) : null);
  if (!player) {
    console.error("video.js player not available");
    return;
  }

  // タイムライン取得（認証が必要なら same-origin）
  let timelines = [];
  try {
    const res = await fetch(url, { credentials: "same-origin" });
    if (!res.ok) {
      console.error("timelines load failed:", res.status);
      return;
    }
    timelines = await res.json();
  } catch (err) {
    console.error("timelines fetch error:", err);
    return;
  }

  // 正規化
  timelines = timelines.map((t) => ({
    id: t.id,
    kind: t.kind,
    start_seconds: Number(t.start_seconds),
    end_seconds: t.end_seconds != null ? Number(t.end_seconds) : null,
    title: t.title,
    body: t.body,
    payload: t.payload || {},
  }));

  let lastHitIds = "";

  const getHits = (time) =>
    timelines.filter((x) => {
      const end = x.end_seconds != null ? x.end_seconds : x.start_seconds;
      return x.start_seconds <= time && end >= time;
    });

  function escapeHtml(s = "") {
    return String(s).replace(/[&<>"']/g, (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])
    );
  }

  function render(hits) {
    if (!hits || hits.length === 0) {
      overlay.innerHTML = "";
      return;
    }
    const first = hits[0];
    overlay.innerHTML = `
      <div class="bg-black/60 text-white p-3 rounded max-w-xl text-center pointer-events-none">
        <div class="font-bold text-lg">${escapeHtml(first.title || first.kind)}</div>
        <div class="mt-1 text-sm">${escapeHtml(first.body || "")}</div>
      </div>
    `;
  }

  // player.ready で登録（video.js のライフサイクルに合わせる）
  player.ready(() => {
    player.on("timeupdate", () => {
      const t = Number(player.currentTime && player.currentTime() !== undefined ? player.currentTime() : 0);
      const hits = getHits(t);
      const hitIds = hits.map((h) => h.id).join(",");
      if (hitIds !== lastHitIds) {
        lastHitIds = hitIds;
        render(hits);
      }
    });

    // 初期描画（再生前の時点を反映）
    const initialTime = Number(player.currentTime ? player.currentTime() : 0);
    render(getHits(initialTime));
  });
}
