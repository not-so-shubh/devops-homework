import React from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';

function App() {
  return (
    <main className="card">
      <p className="eyebrow">Docker Fundamentals</p>
      <h1>Hello World from React</h1>
      <p>Built with Vite and served by Nginx.</p>
    </main>
  );
}

createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
