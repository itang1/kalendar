(function () {
  const { liturgicalInfo, addDays, LiturgicalSeason, LiturgicalColor, SEASON_EXPLANATION, SEASON_CONTEXTUAL_ITEMS } = window.KalendarEngine;

  const TOTAL_DAYS = 366;
  const today = (() => {
    const d = new Date();
    return new Date(d.getFullYear(), d.getMonth(), d.getDate());
  })();

  function dayOfYearOf(date) {
    const start = new Date(date.getFullYear(), 0, 1);
    return Math.round((date - start) / 86400000) + 1;
  }

  const days = [];
  for (let i = 0; i < TOTAL_DAYS; i++) {
    const date = addDays(today, i);
    const info = liturgicalInfo(date);
    days.push({ date, dayOfYear: dayOfYearOf(date), ...info });
  }

  const gridView = document.getElementById('gridView');
  const wheelView = document.getElementById('wheelView');
  const wheelSvg = document.getElementById('wheelSvg');
  const gridBtn = document.getElementById('gridBtn');
  const wheelBtn = document.getElementById('wheelBtn');
  const overlay = document.getElementById('overlay');
  const panel = document.getElementById('panel');

  // MARK: Grid rendering

  function dotColorFor(color) {
    return (color.key === 'white' || color.key === 'rose') ? 'rgba(0,0,0,0.45)' : 'rgba(255,255,255,0.7)';
  }

  days.forEach((day, index) => {
    const tile = document.createElement('div');
    tile.className = 'tile' + (index === 0 ? ' today' : '');
    tile.style.background = day.color.hex;
    if (day.feastName) {
      const dot = document.createElement('div');
      dot.className = 'dot';
      dot.style.background = dotColorFor(day.color);
      tile.appendChild(dot);
    }
    tile.addEventListener('click', () => openDetail(index));
    gridView.appendChild(tile);
  });

  // MARK: Wheel rendering (SVG wedges, today at the top, clockwise)

  const WHEEL_SIZE = 400;
  const CENTER = WHEEL_SIZE / 2;
  const RADIUS = WHEEL_SIZE / 2 - 6;

  function wedgePath(index, total) {
    const sliceAngle = (2 * Math.PI) / total;
    const startAngle = index * sliceAngle - Math.PI / 2;
    const endAngle = startAngle + sliceAngle;
    const x1 = CENTER + RADIUS * Math.cos(startAngle);
    const y1 = CENTER + RADIUS * Math.sin(startAngle);
    const x2 = CENTER + RADIUS * Math.cos(endAngle);
    const y2 = CENTER + RADIUS * Math.sin(endAngle);
    return `M ${CENTER} ${CENTER} L ${x1.toFixed(2)} ${y1.toFixed(2)} A ${RADIUS} ${RADIUS} 0 0 1 ${x2.toFixed(2)} ${y2.toFixed(2)} Z`;
  }

  days.forEach((day, index) => {
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', wedgePath(index, days.length));
    path.setAttribute('fill', day.color.hex);
    path.dataset.index = String(index);
    wheelSvg.appendChild(path);
  });

  const markerAngle = -Math.PI / 2 + ((2 * Math.PI) / days.length) / 2;
  const markerR = RADIUS * 0.85;
  const marker = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
  marker.setAttribute('cx', String(CENTER + markerR * Math.cos(markerAngle)));
  marker.setAttribute('cy', String(CENTER + markerR * Math.sin(markerAngle)));
  marker.setAttribute('r', '6');
  marker.setAttribute('fill', '#f4f4f6');
  marker.setAttribute('stroke', '#1a1a21');
  marker.setAttribute('stroke-width', '1.5');
  wheelSvg.appendChild(marker);

  wheelSvg.addEventListener('click', (e) => {
    const idx = e.target instanceof SVGElement ? e.target.dataset.index : undefined;
    if (idx !== undefined) openDetail(parseInt(idx, 10));
  });

  document.getElementById('openTodayBtn').addEventListener('click', () => openDetail(0));

  // MARK: View toggle

  gridBtn.addEventListener('click', () => setView('grid'));
  wheelBtn.addEventListener('click', () => setView('wheel'));

  function setView(view) {
    const isGrid = view === 'grid';
    gridView.style.display = isGrid ? 'grid' : 'none';
    wheelView.style.display = isGrid ? 'none' : 'flex';
    gridBtn.classList.toggle('active', isGrid);
    wheelBtn.classList.toggle('active', !isGrid);
  }

  // MARK: Detail panel

  const dateFormatter = new Intl.DateTimeFormat('en-US', { month: 'long', day: 'numeric', year: 'numeric' });
  const weekdayFormatter = new Intl.DateTimeFormat('en-US', { weekday: 'long' });

  function seasonColorHex(season) {
    switch (season) {
      case LiturgicalSeason.advent: return LiturgicalColor.violet.hex;
      case LiturgicalSeason.christmas: return LiturgicalColor.white.hex;
      case LiturgicalSeason.ordinaryTime: return LiturgicalColor.green.hex;
      case LiturgicalSeason.lent: return LiturgicalColor.violet.hex;
      case LiturgicalSeason.triduum: return LiturgicalColor.red.hex;
      case LiturgicalSeason.easter: return LiturgicalColor.white.hex;
      default: return LiturgicalColor.green.hex;
    }
  }

  function openDetail(index) {
    renderDetail(index);
    overlay.style.display = 'flex';
    panel.scrollTop = 0;
  }

  function closeDetail() {
    overlay.style.display = 'none';
  }

  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) closeDetail();
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeDetail();
  });

  function renderDetail(index) {
    const day = days[index];
    const seasonItems = SEASON_CONTEXTUAL_ITEMS[day.season] || [];
    const seasonExplanation = SEASON_EXPLANATION[day.season] || '';

    const rankExplanation = day.isSolemnity
      ? "A solemnity is the highest rank of celebration in Christian worship. These mark the most important mysteries and events of the faith, like Easter, Christmas, or major saints. They take priority over the regular season."
      : "Feasts and memorials are celebrations of saints or events in the life of Jesus and Mary. A feast is more important than a memorial. Some memorials are optional, while others are observed throughout Christianity.";

    panel.innerHTML = `
      <div class="panel-header">
        <div>
          <h2>${dateFormatter.format(day.date)} (${weekdayFormatter.format(day.date)})</h2>
          <div class="day-of-year">Day ${day.dayOfYear} of the year</div>
        </div>
        <button class="close-btn" id="closeBtn" aria-label="Close">&times;</button>
      </div>

      <div class="label">Season</div>
      <div class="swatch-row">
        <div class="swatch" style="background:${seasonColorHex(day.season)}"></div>
        <strong>${day.season}</strong>${day.weekOfSeason != null ? ` &middot; Week ${day.weekOfSeason}` : ''}
      </div>
      <p>${seasonExplanation}</p>
      <p style="font-weight:600">Traditionally during ${day.season}:</p>
      <ul class="items">${seasonItems.map((item) => `<li>${item}</li>`).join('')}</ul>

      ${day.feastName ? `
        <div class="label">${day.isSolemnity ? 'Solemnity' : 'Feast / Memorial'}</div>
        <div class="swatch-row">
          ${day.isSolemnity ? '<span class="star">&#9733;</span>' : ''}
          <span class="feast-name">${day.feastName}</span>
        </div>
        <p>${day.feastDescription || ''}</p>
        <p>${rankExplanation}</p>
      ` : ''}

      <div class="label">Vestment</div>
      <div class="swatch-row">
        <div class="swatch" style="background:${day.color.hex}; border-radius:50%;"></div>
        <strong>${day.color.name}</strong>
      </div>
      <p>The priest wears vestments of this color at Mass. The color reflects the character of the season or feast.</p>

      <div class="nav-row">
        <button id="prevBtn" ${index === 0 ? 'disabled' : ''}>&larr; Previous</button>
        <button id="nextBtn" ${index === days.length - 1 ? 'disabled' : ''}>Next &rarr;</button>
      </div>
    `;

    document.getElementById('closeBtn').addEventListener('click', closeDetail);
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    if (prevBtn) prevBtn.addEventListener('click', () => openDetail(index - 1));
    if (nextBtn) nextBtn.addEventListener('click', () => openDetail(index + 1));
  }
})();
