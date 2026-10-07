import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import "./styles.css";

const emptyRelease = {service: "", version: "", environment: "staging", status: "planned", owner: "", notes: ""};
const statusOrder = ["planned", "deploying", "healthy", "failed", "rolled-back"];

function App() {
  const [releases, setReleases] = useState([]);
  const [form, setForm] = useState(emptyRelease);
  const [editingId, setEditingId] = useState(null);
  const [filter, setFilter] = useState("all");
  const [message, setMessage] = useState("Connecting to delivery data…");

  const loadReleases = async () => {
    try {
      const response = await fetch("/api/releases");
      if (!response.ok) throw new Error("API unavailable");
      const data = await response.json();
      setReleases(data);
      setMessage(data.length ? `${data.length} releases loaded` : "Ready for your first release");
    } catch (error) { setMessage(error.message); }
  };

  useEffect(() => { loadReleases(); }, []);

  const stats = useMemo(() => ({
    total: releases.length,
    healthy: releases.filter((item) => item.status === "healthy").length,
    active: releases.filter((item) => item.status === "deploying").length,
    failed: releases.filter((item) => item.status === "failed").length,
  }), [releases]);
  const visible = filter === "all" ? releases : releases.filter((item) => item.status === filter);

  const submit = async (event) => {
    event.preventDefault();
    const response = await fetch(editingId ? `/api/releases/${editingId}` : "/api/releases", {
      method: editingId ? "PUT" : "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify(form),
    });
    if (!response.ok) { setMessage("Please check every field and try again"); return; }
    setForm(emptyRelease);
    setEditingId(null);
    setMessage(editingId ? "Release updated" : "Release recorded");
    await loadReleases();
  };

  const edit = (release) => {
    const {id, created_at: ignored, ...editable} = release;
    void ignored;
    setEditingId(id);
    setForm(editable);
    window.scrollTo({top: 0, behavior: "smooth"});
  };

  const remove = async (id) => {
    if (!window.confirm("Delete this release record?")) return;
    if ((await fetch(`/api/releases/${id}`, {method: "DELETE"})).ok) {
      setMessage("Release deleted");
      await loadReleases();
    }
  };

  return (
    <div className="app-shell">
      <header className="hero">
        <div><p className="eyebrow">Platform operations</p><h1>Release Tracker</h1><p className="subtitle">A clear view of every service moving through your delivery environments.</p></div>
        <div className="live-pill"><span /> API connected</div>
      </header>
      <section className="stats" aria-label="Release statistics">
        <article><span>All releases</span><strong>{stats.total}</strong></article>
        <article><span>Healthy</span><strong>{stats.healthy}</strong></article>
        <article><span>Deploying</span><strong>{stats.active}</strong></article>
        <article><span>Needs attention</span><strong>{stats.failed}</strong></article>
      </section>
      <main className="workspace">
        <section className="panel form-panel">
          <div className="panel-heading">
            <div><p className="eyebrow">Change record</p><h2>{editingId ? "Update release" : "Track a release"}</h2></div>
            {editingId && <button className="text-button" onClick={() => { setEditingId(null); setForm(emptyRelease); }}>Cancel</button>}
          </div>
          <form onSubmit={submit}>
            <label>Service<input required minLength="2" placeholder="payments-api" value={form.service} onChange={(e) => setForm({...form, service: e.target.value})} /></label>
            <div className="form-row">
              <label>Version<input required placeholder="2.4.0" value={form.version} onChange={(e) => setForm({...form, version: e.target.value})} /></label>
              <label>Owner<input required minLength="2" placeholder="Platform team" value={form.owner} onChange={(e) => setForm({...form, owner: e.target.value})} /></label>
            </div>
            <div className="form-row">
              <label>Environment<select value={form.environment} onChange={(e) => setForm({...form, environment: e.target.value})}><option>development</option><option>staging</option><option>production</option></select></label>
              <label>Status<select value={form.status} onChange={(e) => setForm({...form, status: e.target.value})}>{statusOrder.map((item) => <option key={item}>{item}</option>)}</select></label>
            </div>
            <label>Notes<textarea maxLength="280" placeholder="Canary scope, verification notes, or rollback context" value={form.notes} onChange={(e) => setForm({...form, notes: e.target.value})} /></label>
            <button className="primary" type="submit">{editingId ? "Save changes" : "Record release"}</button>
          </form>
        </section>
        <section className="panel list-panel">
          <div className="panel-heading">
            <div><p className="eyebrow">Delivery timeline</p><h2>Recent releases</h2></div>
            <select aria-label="Filter by status" value={filter} onChange={(e) => setFilter(e.target.value)}><option value="all">All statuses</option>{statusOrder.map((item) => <option key={item}>{item}</option>)}</select>
          </div>
          <p className="message" role="status">{message}</p>
          <div className="release-list">
            {visible.length === 0 && <div className="empty"><strong>No matching releases</strong><span>New delivery records will appear here.</span></div>}
            {visible.map((release) => <article className="release-card" key={release.id}>
              <div className="release-top"><div><h3>{release.service}</h3><code>v{release.version}</code></div><span className={`status status-${release.status}`}>{release.status}</span></div>
              <p>{release.notes || "No release notes provided."}</p>
              <footer><span>{release.environment} · {release.owner}</span><div><button onClick={() => edit(release)}>Edit</button><button className="danger" onClick={() => remove(release.id)}>Delete</button></div></footer>
            </article>)}
          </div>
        </section>
      </main>
      <footer className="page-footer">Release Tracker · observable, secure, and GitOps-ready</footer>
    </div>
  );
}

createRoot(document.getElementById("root")).render(<React.StrictMode><App /></React.StrictMode>);
