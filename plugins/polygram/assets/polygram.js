// polygram_player.js (native HTML5 video, OO-style)

class PolygramVideoPlayer {

    constructor({
        videoId = "annotation-video",
        timelineId = "timeline",
        timestampId = "video-is-at-timestamp",
        speedSliderId = "playspeed",
        speedValueId = "playspeed-value",
        markers = [],
        defaultSlowRate = 0.3,
        defaultSlowSeconds = 5,
    } = {}) {
        this.video = document.getElementById(videoId);
        this.timelineEl = document.getElementById(timelineId);

        this.timestampEl = document.getElementById(timestampId);
        this.speedSlider = document.getElementById(speedSliderId);
        this.speedValueEl = document.getElementById(speedValueId);

        this.markers = markers;

        this.defaultSlowRate = defaultSlowRate;
        this.defaultSlowSeconds = defaultSlowSeconds;

        this._slowmoTimer = null;

        this._onTimeUpdate = this._onTimeUpdate.bind(this);
        this._onHashChange = this._onHashChange.bind(this);
        this._afterMetadata = this._afterMetadata.bind(this);
    }

    init() {
        if (!this.video || !this.timelineEl) return;

        this._bindVideoTimeOverlay();
        this._bindSpeedSlider();
        this._bindHashHotlinks();

        // Render markers once duration is known
        if (Number.isFinite(this.video.duration) && this.video.duration > 0) {
            this._afterMetadata();
        } else {
            this.video.addEventListener("loadedmetadata", this._afterMetadata, { once: true });
            // Some browsers update duration later
            this.video.addEventListener(
                "durationchange",
                () => {
                    if (Number.isFinite(this.video.duration) && this.video.duration > 0) this._afterMetadata();
                }, { once: true }
            );
        }
    }

    setMarkers(markers) {
        this.markers = Array.isArray(markers) ? markers : [];
        this.renderMarkers();
    }

    jumpWithSlowmo(t, slowRate = this.defaultSlowRate, slowSeconds = this.defaultSlowSeconds) {
        const apply = () => {
            this.video.currentTime = this._clamp(t, 0, Math.max(0, (this.video.duration || 0) - 0.001));

            history.replaceState(null, "", `#t=${Math.floor(t)}`);

            this.setPlaySpeed(slowRate);

            const p = this.video.play();
            if (p && typeof p.catch === "function") p.catch(() => {});

            if (this._slowmoTimer) window.clearTimeout(this._slowmoTimer);
            this._slowmoTimer = window.setTimeout(() => {
                this.setPlaySpeed(1.0);
                this._slowmoTimer = null;
            }, Math.round(slowSeconds * 1000));
        };

        if (!Number.isFinite(this.video.duration) || this.video.readyState < 1) {
            this.video.addEventListener("loadedmetadata", apply, { once: true });
        } else {
            apply();
        }
    }

    setPlaySpeed(value) {
        const v = this._clamp(Number(value), 0.1, 2.0);

        if (this.speedSlider) this.speedSlider.value = String(v);
        if (this.speedValueEl) this.speedValueEl.textContent = v.toFixed(2);

        this.video.playbackRate = v;
    }

    // ---------- Internals ----------
    _afterMetadata() {
        this.renderMarkers();
        this._seekFromHash(); // hotlink on initial load
        this._onTimeUpdate(); // initial overlay update
    }

    renderMarkers() {
        const duration = this.video.duration;
        if (!this.timelineEl || !Number.isFinite(duration) || duration <= 0) return;

        this.timelineEl.innerHTML = "";

        for (const m of this.markers) {
            const pct = this._clamp((m.ts / duration) * 100, 0, 100);

            const dot = document.createElement("button");
            dot.type = "button";
            dot.className = "marker";
            dot.style.left = `${pct}%`;
            dot.title = m.label ?? this._formatTs(m.ts);
            dot.addEventListener("click", () => this.jumpWithSlowmo(m.ts));

            this.timelineEl.appendChild(dot);
        }
    }

    _bindVideoTimeOverlay() {
        // frequent updates while playing
        this.video.addEventListener("timeupdate", this._onTimeUpdate);

        // update on seeks and state changes too
        this.video.addEventListener("seeked", this._onTimeUpdate);
        this.video.addEventListener("pause", this._onTimeUpdate);
        this.video.addEventListener("play", this._onTimeUpdate);
    }

    _onTimeUpdate() {
        if (!this.timestampEl) return;
        this.timestampEl.textContent = String(Math.floor(this.video.currentTime || 0));
    }

    _bindSpeedSlider() {
        if (!this.speedSlider) return;

        const sync = () => {
            const v = this._clamp(Number(this.speedSlider.value), 0.1, 2.0);
            if (this.speedValueEl) this.speedValueEl.textContent = v.toFixed(2);
            this.video.playbackRate = v;
        };

        this.speedSlider.addEventListener("input", sync);
        this.speedSlider.addEventListener("change", sync);

        // initial
        sync();
    }

    _bindHashHotlinks() {
        window.addEventListener("hashchange", this._onHashChange);
    }

    _onHashChange() {
        this._seekFromHash();
    }

    _seekFromHash() {
        const hash = window.location.hash;
        if (!hash || hash.length < 2) return;

        const params = new URLSearchParams(hash.slice(1));

        const t = Number(params.get("t"));
        if (!Number.isFinite(t)) return;

        const d = Number(params.get("d"));

        if (Number.isFinite(d) && d > 0) {
            this.jumpWithSlowmo(t, this.defaultSlowRate, d);
        } else {
            this.jumpWithSlowmo(t);
        }
    }

    _clamp(n, min, max) {
        return Math.min(max, Math.max(min, n));
    }

    _formatTs(sec) {
        const s = Math.max(0, Number(sec) || 0);
        const m = Math.floor(s / 60);
        const r = s - m * 60;
        const ss = Math.floor(r);
        const ms = Math.round((r - ss) * 1000);
        return `${m}:${String(ss).padStart(2, "0")}.${String(ms).padStart(3, "0")}`;
    }
}

// Boot
document.addEventListener("DOMContentLoaded", () => {
    const player = new PolygramVideoPlayer({
        markers: [
            { ts: 4, label: "avoid gaze" },
            { ts: 14, label: "avoid gaze" },
        ],
        defaultSlowRate: 0.3,
        defaultSlowSeconds: 5,
    });

    player.init();
});
