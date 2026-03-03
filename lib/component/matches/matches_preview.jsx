import { useState, useEffect } from "react";

// ─── DATA ──────────────────────────────────────────────────────────────────

const TEAMS = {
  fcb:  { id:"fcb",  name:"FC Barcelona",        short:"FCB", color:"#004D98", color2:"#A50044" },
  rma:  { id:"rma",  name:"Real Madrid",          short:"RMA", color:"#F0E68C", color2:"#1a1a1a" },
  atm:  { id:"atm",  name:"Atlético Madrid",      short:"ATM", color:"#CB3524", color2:"#FFFFFF" },
  psg:  { id:"psg",  name:"Paris Saint-Germain",  short:"PSG", color:"#003F8A", color2:"#E30613" },
  int:  { id:"int",  name:"Inter Milan",          short:"INT", color:"#010E80", color2:"#000000" },
  sev:  { id:"sev",  name:"Sevilla FC",           short:"SEV", color:"#D91A21", color2:"#FFFFFF" },
  osa:  { id:"osa",  name:"CA Osasuna",           short:"OSA", color:"#D0021B", color2:"#000000" },
  vil:  { id:"vil",  name:"Villarreal CF",        short:"VIL", color:"#F8DC3F", color2:"#004494" },
  val:  { id:"val",  name:"Valencia CF",          short:"VAL", color:"#F7A700", color2:"#000000" },
  bet:  { id:"bet",  name:"Real Betis",           short:"BET", color:"#00954C", color2:"#FFFFFF" },
  get:  { id:"get",  name:"Getafe CF",            short:"GET", color:"#5B9BD5", color2:"#000000" },
  cel:  { id:"cel",  name:"Celta Vigo",           short:"CEL", color:"#79C5E8", color2:"#FFFFFF" },
};

const COMP = {
  laliga: { label:"La Liga",   short:"La Liga", color:"#FF6B35" },
  ucl:    { label:"Champions", short:"UCL",     color:"#4FC3F7" },
  copa:   { label:"Copa del Rey", short:"Copa", color:"#AB47BC" },
};

const now = new Date();
const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
const h = (hrs, min=0) => new Date(today.getTime() + hrs*3600000 + min*60000);
const future = (days, hrs=21) => new Date(today.getTime() + days*86400000 + hrs*3600000);

const MATCHES = [
  // LIVE
  { id:"l1", home:TEAMS.fcb, away:TEAMS.rma, comp:COMP.laliga, status:"live",
    kickoff:h(21), homeScore:2, awayScore:1, minute:67, fav:true },
  // Today upcoming
  { id:"u1", home:TEAMS.atm, away:TEAMS.sev, comp:COMP.laliga, status:"upcoming", kickoff:h(16) },
  { id:"u2", home:TEAMS.vil, away:TEAMS.val, comp:COMP.laliga, status:"upcoming", kickoff:h(18,30) },
  { id:"u3", home:TEAMS.bet, away:TEAMS.osa, comp:COMP.laliga, status:"upcoming", kickoff:h(20) },
  { id:"u4", home:TEAMS.get, away:TEAMS.cel, comp:COMP.laliga, status:"upcoming", kickoff:h(22) },
  // Finished
  { id:"f1", home:TEAMS.int, away:TEAMS.psg, comp:COMP.ucl, status:"finished",
    kickoff:h(14), homeScore:1, awayScore:3 },
  // Barca upcoming
  { id:"b1", home:TEAMS.fcb, away:TEAMS.int, comp:COMP.ucl, status:"upcoming",
    kickoff:future(3,21), fav:true },
  { id:"b2", home:TEAMS.osa, away:TEAMS.fcb, comp:COMP.copa, status:"upcoming",
    kickoff:future(6,19), fav:true },
];

// ─── STYLES ────────────────────────────────────────────────────────────────
const css = `
  @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&family=DM+Sans:wght@400;500;600&family=JetBrains+Mono:wght@400;500;600&display=swap');

  *, *::before, *::after { box-sizing:border-box; margin:0; padding:0; }
  :root {
    --sky:   #010916;
    --mid:   #041228;
    --pri:   #00BFFF;
    --glow:  #1E90FF;
    --glass: rgba(255,255,255,0.06);
    --gb:    rgba(255,255,255,0.12);
    --t1:    #EFF6FF;
    --t2:    #B8D4F0;
    --t3:    #6A9BC3;
    --live:  #FF4757;
    --win:   #06D6A0;
    --bb:    #004D98;
    --br:    #A50044;
  }
  html,body,#root { height:100%; }
  body {
    background:
      radial-gradient(ellipse 70% 60% at 15% 0%, #0d2a52 0%, transparent 55%),
      radial-gradient(ellipse 50% 40% at 85% 100%, #06091a 0%, transparent 55%),
      var(--sky);
    font-family:'DM Sans',sans-serif; color:var(--t1); overflow:hidden;
  }

  /* shell */
  .shell { display:flex; flex-direction:column; height:100vh; padding:28px 28px 20px; gap:18px; }

  /* topbar */
  .topbar { display:flex; align-items:flex-end; justify-content:space-between; flex-shrink:0; }
  .topbar-left h1 { font-family:'Outfit',sans-serif; font-size:24px; font-weight:800; letter-spacing:-0.5px; }
  .topbar-left p  { font-size:13px; color:var(--t3); margin-top:2px; }
  .fav-badge {
    display:flex; align-items:center; gap:7px;
    padding:7px 14px; border-radius:10px;
    background:linear-gradient(135deg,rgba(0,77,152,0.25),rgba(165,0,68,0.2));
    border:1px solid rgba(0,77,152,0.35);
    font-family:'Outfit',sans-serif; font-size:13px; font-weight:600;
  }
  .fav-heart { color:var(--br); font-size:14px; }

  /* columns */
  .cols { display:flex; gap:16px; flex:1; min-height:0; }

  /* panel */
  .panel {
    background:var(--glass); border:1px solid var(--gb);
    border-radius:20px; overflow:hidden;
    display:flex; flex-direction:column; min-height:0;
  }
  .panel-accent { height:3px; flex-shrink:0; }
  .panel-header {
    display:flex; align-items:center; gap:10px;
    padding:14px 18px 12px; flex-shrink:0;
    border-bottom:1px solid var(--gb);
  }
  .panel-icon {
    width:34px; height:34px; border-radius:9px;
    display:flex; align-items:center; justify-content:center;
    font-size:16px; border:1px solid; flex-shrink:0;
  }
  .panel-title { font-family:'Outfit',sans-serif; font-size:15px; font-weight:700; }
  .panel-scroll { flex:1; overflow-y:auto; padding:14px; scrollbar-width:thin; scrollbar-color:rgba(255,255,255,0.1) transparent; min-height:0; }
  .panel-scroll::-webkit-scrollbar { width:3px; }
  .panel-scroll::-webkit-scrollbar-thumb { background:rgba(255,255,255,0.1); border-radius:2px; }

  /* crest */
  .crest {
    display:flex; align-items:center; justify-content:center;
    border-radius:25%; border:1.5px solid; flex-shrink:0;
    font-family:'JetBrains Mono',monospace; font-weight:700;
  }

  /* pill */
  .pill {
    display:inline-flex; align-items:center;
    padding:2px 8px; border-radius:100px; border:1px solid;
    font-family:'JetBrains Mono',monospace; font-size:9px; font-weight:600;
  }

  /* live indicator */
  .live-pill {
    display:inline-flex; align-items:center; gap:5px;
    padding:3px 9px; border-radius:100px;
    background:rgba(255,71,87,0.12); border:1px solid rgba(255,71,87,0.3);
    font-family:'JetBrains Mono',monospace; font-size:9px; font-weight:600; color:var(--live);
  }
  .live-dot {
    width:5px; height:5px; border-radius:50%; background:var(--live);
    animation:pulse 1.1s ease-in-out infinite;
  }
  @keyframes pulse {
    0%,100% { box-shadow:0 0 3px rgba(255,71,87,0.4); }
    50%      { box-shadow:0 0 8px rgba(255,71,87,0.8); }
  }

  /* ── LIVE HERO ── */
  .live-hero {
    border-radius:18px; padding:18px; margin-bottom:12px;
    background:rgba(255,71,87,0.06);
    border:1px solid rgba(255,71,87,0.22);
    box-shadow:0 0 24px rgba(255,71,87,0.07), 0 6px 16px rgba(1,9,22,0.5);
    position:relative; overflow:hidden;
  }
  .hero-glow-l {
    position:absolute; left:-40px; top:-40px;
    width:120px; height:120px; border-radius:50%;
    background:radial-gradient(circle, rgba(0,77,152,0.2), transparent);
    pointer-events:none;
  }
  .hero-glow-r {
    position:absolute; right:-40px; bottom:-40px;
    width:120px; height:120px; border-radius:50%;
    background:radial-gradient(circle, rgba(165,0,68,0.2), transparent);
    pointer-events:none;
  }
  .hero-top { display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; }
  .hero-teams { display:flex; align-items:center; justify-content:space-between; gap:8px; }
  .hero-team { display:flex; flex-direction:column; align-items:center; gap:8px; flex:1; }
  .hero-name { font-family:'Outfit',sans-serif; font-size:12px; font-weight:600; text-align:center; }
  .hero-score {
    display:flex; align-items:baseline; gap:6px;
    font-family:'Outfit',sans-serif; font-size:48px; font-weight:800; letter-spacing:-2px;
  }
  .hero-score-sep { font-size:32px; color:var(--t3); }
  .hero-venue { text-align:center; font-size:11px; color:var(--t3); margin-top:14px; }

  /* ── NEXT MATCH CARD ── */
  .next-card {
    border-radius:16px; padding:16px; margin-bottom:12px;
    background:rgba(0,77,152,0.08); border:1px solid rgba(0,77,152,0.22);
    box-shadow:0 0 18px rgba(0,77,152,0.07);
  }
  .next-label { font-size:12px; color:var(--t3); margin-bottom:12px;
    display:flex; justify-content:space-between; align-items:center; }
  .next-teams { display:flex; align-items:center; gap:10px; margin-bottom:14px; }
  .next-vs { display:flex; flex-direction:column; gap:2px; flex:1; }
  .next-tname { font-family:'Outfit',sans-serif; font-size:13px; font-weight:600; }
  .next-vs-sep { font-size:11px; color:var(--t3); }
  .divider { height:1px; background:var(--gb); margin:12px 0; }
  .next-date { display:flex; align-items:center; gap:6px; font-size:12px; color:var(--t3); margin-bottom:10px; }

  /* countdown */
  .countdown { display:flex; align-items:center; justify-content:space-between; }
  .cd-unit { display:flex; flex-direction:column; align-items:center; gap:4px; }
  .cd-box {
    width:50px; height:42px; border-radius:9px;
    background:rgba(255,255,255,0.05); border:1px solid var(--gb);
    display:flex; align-items:center; justify-content:center;
    font-family:'Outfit',sans-serif; font-size:20px; font-weight:800; color:var(--pri);
  }
  .cd-label { font-family:'JetBrains Mono',monospace; font-size:8px; color:var(--t3); font-weight:500; }
  .cd-sep { font-family:'Outfit',sans-serif; font-size:20px; font-weight:800; color:var(--t3); padding-bottom:16px; }

  /* fixture row */
  .fix-row {
    display:flex; align-items:center; gap:10px;
    padding:10px 12px; border-radius:12px;
    background:rgba(255,255,255,0.04); border:1px solid var(--gb);
    margin-bottom:7px;
  }
  .ha-badge {
    width:24px; text-align:center; padding:2px 0; border-radius:5px; border:1px solid;
    font-family:'JetBrains Mono',monospace; font-size:9px; font-weight:600; flex-shrink:0;
  }
  .fix-name { font-family:'Outfit',sans-serif; font-size:12px; font-weight:600; flex:1;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .fix-right { display:flex; flex-direction:column; align-items:flex-end; gap:3px; flex-shrink:0; }
  .fix-date { font-family:'JetBrains Mono',monospace; font-size:9px; color:var(--t3); }

  /* section label */
  .sec-label { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
  .sec-bar { width:3px; height:12px; border-radius:2px; flex-shrink:0; }
  .sec-text { font-family:'Outfit',sans-serif; font-size:12px; font-weight:600; }
  .sec-rule { flex:1; height:1px; }
  .sec-wrap { margin-bottom:14px; }

  /* match row card */
  .match-row {
    display:flex; align-items:stretch; border-radius:14px; overflow:hidden;
    background:rgba(255,255,255,0.04); border:1px solid var(--gb);
    margin-bottom:8px;
  }
  .match-row.live-row { border-color:rgba(255,71,87,0.3); }
  .mr-bar { width:3px; flex-shrink:0; }
  .mr-body { display:flex; align-items:center; padding:11px 14px; gap:10px; flex:1; }
  .mr-team { display:flex; align-items:center; gap:8px; flex:1; }
  .mr-team.right { flex-direction:row-reverse; }
  .mr-tname { font-family:'Outfit',sans-serif; font-size:13px; font-weight:600;
    white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .mr-centre { display:flex; flex-direction:column; align-items:center; gap:4px; min-width:70px; }
  .mr-time { font-family:'JetBrains Mono',monospace; font-size:17px; font-weight:600; color:var(--t1); }
  .mr-score { display:flex; align-items:baseline; gap:3px;
    font-family:'Outfit',sans-serif; font-size:20px; font-weight:800; }
  .mr-sep { font-size:14px; color:var(--t3); }

  /* count badge */
  .count-badge {
    margin-left:auto;
    padding:3px 9px; border-radius:100px;
    background:rgba(0,191,255,0.12); border:1px solid rgba(0,191,255,0.25);
    font-family:'JetBrains Mono',monospace; font-size:10px; font-weight:600; color:var(--pri);
  }

  .fixtures-label { font-size:12px; color:var(--t3); margin-bottom:8px; font-weight:600; font-family:'Outfit',sans-serif; }
`;

// ─── HELPERS ───────────────────────────────────────────────────────────────

function Crest({ team, size = 36 }) {
  const fs = size * 0.28;
  return (
    <div className="crest" style={{
      width: size, height: size, fontSize: fs,
      background: team.color + "28",
      borderColor: team.color + "55",
      color: team.color,
    }}>
      {team.short}
    </div>
  );
}

function Pill({ label, color }) {
  return (
    <span className="pill" style={{
      background: color + "1a", borderColor: color + "33", color
    }}>{label}</span>
  );
}

function LiveIndicator({ minute }) {
  return (
    <span className="live-pill">
      <span className="live-dot" />
      {minute ? `${minute}'` : "LIVE"}
    </span>
  );
}

function fmtTime(dt) {
  return `${String(dt.getHours()).padStart(2,"0")}:${String(dt.getMinutes()).padStart(2,"0")}`;
}
function fmtDate(dt) {
  const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
  return `${months[dt.getMonth()]} ${dt.getDate()}  ·  ${fmtTime(dt)}`;
}

// ─── COUNTDOWN ─────────────────────────────────────────────────────────────

function Countdown({ kickoff }) {
  const [rem, setRem] = useState(0);
  useEffect(() => {
    const tick = () => setRem(Math.max(0, kickoff - Date.now()));
    tick();
    const t = setInterval(tick, 1000);
    return () => clearInterval(t);
  }, [kickoff]);

  const total = Math.floor(rem / 1000);
  const d = Math.floor(total / 86400);
  const h = Math.floor((total % 86400) / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = total % 60;
  const pad = n => String(n).padLeft ? String(n).padStart(2,"0") : n.toString().padStart(2,"0");

  return (
    <div className="countdown">
      {[{v:d,l:"DAYS"},{v:h,l:"HRS"},{v:m,l:"MIN"},{v:s,l:"SEC"}].map((u,i) => (
        <>
          {i > 0 && <span className="cd-sep">:</span>}
          <div className="cd-unit" key={u.l}>
            <div className="cd-box">{pad(u.v)}</div>
            <span className="cd-label">{u.l}</span>
          </div>
        </>
      ))}
    </div>
  );
}

// ─── LIVE HERO ─────────────────────────────────────────────────────────────

function LiveHero({ match }) {
  return (
    <div className="live-hero">
      <div className="hero-glow-l" /><div className="hero-glow-r" />
      <div className="hero-top">
        <Pill label={match.comp.label} color={match.comp.color} />
        <LiveIndicator minute={match.minute} />
      </div>
      <div className="hero-teams">
        <div className="hero-team">
          <Crest team={match.home} size={48} />
          <span className="hero-name">{match.home.name}</span>
        </div>
        <div className="hero-score">
          <span>{match.homeScore}</span>
          <span className="hero-score-sep">–</span>
          <span>{match.awayScore}</span>
        </div>
        <div className="hero-team">
          <Crest team={match.away} size={48} />
          <span className="hero-name">{match.away.name}</span>
        </div>
      </div>
      <div className="hero-venue">Estadio Olímpico Lluís Companys · Barcelona</div>
    </div>
  );
}

// ─── NEXT MATCH ────────────────────────────────────────────────────────────

function NextMatchCard({ match }) {
  const isHome = match.home.id === "fcb";
  const opponent = isHome ? match.away : match.home;

  return (
    <div className="next-card">
      <div className="next-label">
        <span>Next Match</span>
        <Pill label={match.comp.short} color={match.comp.color} />
      </div>
      <div className="next-teams">
        <Crest team={match.home} size={40} />
        <div className="next-vs">
          <span className="next-tname">{match.home.name}</span>
          <span className="next-vs-sep">vs</span>
          <span className="next-tname">{match.away.name}</span>
        </div>
        <Crest team={match.away} size={40} />
      </div>
      <div className="divider" />
      <div className="next-date">
        <span>📅</span>
        <span>{fmtDate(match.kickoff)}</span>
      </div>
      <Countdown kickoff={match.kickoff.getTime()} />
    </div>
  );
}

// ─── FIXTURE ROW ───────────────────────────────────────────────────────────

function FixtureRow({ match }) {
  const isHome = match.home.id === "fcb";
  const opponent = isHome ? match.away : match.home;
  return (
    <div className="fix-row">
      <span className="ha-badge" style={{
        color: isHome ? "#4FC3F7" : "#6A9BC3",
        borderColor: (isHome ? "#4FC3F7" : "#6A9BC3") + "33",
        background: (isHome ? "#4FC3F7" : "#6A9BC3") + "15",
      }}>{isHome ? "H" : "A"}</span>
      <Crest team={opponent} size={26} />
      <span className="fix-name">{opponent.name}</span>
      <div className="fix-right">
        <Pill label={match.comp.short} color={match.comp.color} />
        <span className="fix-date">{fmtDate(match.kickoff)}</span>
      </div>
    </div>
  );
}

// ─── MATCH ROW ─────────────────────────────────────────────────────────────

function MatchRow({ match }) {
  const isLive = match.status === "live";
  const barColor = isLive ? "#FF4757" : match.status === "upcoming" ? "#00BFFF" : "#6A9BC3";

  return (
    <div className={`match-row${isLive ? " live-row" : ""}`}>
      <div className="mr-bar" style={{
        background: barColor,
        boxShadow: isLive ? `0 0 6px ${barColor}88` : "none"
      }} />
      <div className="mr-body">
        <div className="mr-team">
          <Crest team={match.home} size={30} />
          <span className="mr-tname">{match.home.name}</span>
        </div>
        <div className="mr-centre">
          {match.status === "upcoming"
            ? <span className="mr-time">{fmtTime(match.kickoff)}</span>
            : <div className="mr-score">
                <span>{match.homeScore}</span>
                <span className="mr-sep">–</span>
                <span>{match.awayScore}</span>
              </div>
          }
          {isLive
            ? <LiveIndicator minute={match.minute} />
            : <Pill label={match.comp.short} color={match.comp.color} />
          }
        </div>
        <div className="mr-team right">
          <Crest team={match.away} size={30} />
          <span className="mr-tname">{match.away.name}</span>
        </div>
      </div>
    </div>
  );
}

// ─── SECTION LABEL ─────────────────────────────────────────────────────────

function SectionLabel({ label, color }) {
  return (
    <div className="sec-label">
      <div className="sec-bar" style={{ background: color, boxShadow: `0 0 4px ${color}88` }} />
      <span className="sec-text" style={{ color }}>{label}</span>
      <div className="sec-rule" style={{
        background: `linear-gradient(90deg,${color}44,transparent)`
      }} />
    </div>
  );
}

// ─── ROOT APP ───────────────────────────────────────────────────────────────

export default function App() {
  const live     = MATCHES.filter(m => m.status === "live");
  const upcoming = MATCHES.filter(m => m.status === "upcoming" &&
    new Date(m.kickoff).toDateString() === today.toDateString());
  const finished = MATCHES.filter(m => m.status === "finished");
  const barcaLive= MATCHES.find(m => m.status === "live" && m.fav);
  const barcaNext= MATCHES.find(m => m.status === "upcoming" && m.fav);
  const barcaFix = MATCHES.filter(m => m.fav && m.status === "upcoming" && m !== barcaNext);

  const days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
  const months = ["January","February","March","April","May","June",
                  "July","August","September","October","November","December"];
  const dateLabel = `${days[now.getDay()]}, ${now.getDate()} ${months[now.getMonth()]}`;
  const totalToday = live.length + upcoming.length + finished.length;

  return (
    <>
      <style>{css}</style>
      <div className="shell">

        {/* Top bar */}
        <div className="topbar">
          <div className="topbar-left">
            <h1>Matches</h1>
            <p>{dateLabel}</p>
          </div>
          <div className="fav-badge">
            <span className="fav-heart">♥</span>
            FC Barcelona
          </div>
        </div>

        {/* Columns */}
        <div className="cols">

          {/* LEFT — Barça */}
          <div className="panel" style={{ width: 340, flexShrink: 0 }}>
            <div className="panel-accent" style={{
              background: "linear-gradient(90deg, #004D98, #A50044)"
            }} />
            <div className="panel-header">
              <div className="panel-icon" style={{
                background:"rgba(0,77,152,0.15)", borderColor:"rgba(0,77,152,0.3)", color:"#A50044"
              }}>♥</div>
              <span className="panel-title">FC Barcelona</span>
            </div>
            <div className="panel-scroll">
              {barcaLive && <LiveHero match={barcaLive} />}
              {barcaNext && <NextMatchCard match={barcaNext} />}
              {barcaFix.length > 0 && (
                <>
                  <div className="fixtures-label">Upcoming Fixtures</div>
                  {barcaFix.map(m => <FixtureRow key={m.id} match={m} />)}
                </>
              )}
            </div>
          </div>

          {/* RIGHT — Today */}
          <div className="panel" style={{ flex: 1 }}>
            <div className="panel-accent" style={{
              background: "linear-gradient(90deg,#00BFFF,#1E90FF,transparent)"
            }} />
            <div className="panel-header">
              <div className="panel-icon" style={{
                background:"rgba(0,191,255,0.12)", borderColor:"rgba(0,191,255,0.25)", color:"#00BFFF"
              }}>📅</div>
              <span className="panel-title">Today's Matches</span>
              <span className="count-badge">{totalToday} matches</span>
            </div>
            <div className="panel-scroll">
              {live.length > 0 && (
                <div className="sec-wrap">
                  <SectionLabel label="Live Now" color="#FF4757" />
                  {live.map(m => <MatchRow key={m.id} match={m} />)}
                </div>
              )}
              {upcoming.length > 0 && (
                <div className="sec-wrap">
                  <SectionLabel label="Upcoming" color="#00BFFF" />
                  {upcoming.map(m => <MatchRow key={m.id} match={m} />)}
                </div>
              )}
              {finished.length > 0 && (
                <div className="sec-wrap">
                  <SectionLabel label="Finished" color="#6A9BC3" />
                  {finished.map(m => <MatchRow key={m.id} match={m} />)}
                </div>
              )}
            </div>
          </div>

        </div>
      </div>
    </>
  );
}
