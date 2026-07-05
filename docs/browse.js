(function () {
  const { liturgicalInfo, liturgicalDayTitle, keyDates, addDays, daysBetween, LiturgicalSeason, LiturgicalColor, SEASON_EXPLANATION, SEASON_CONTEXTUAL_ITEMS, COLOR_EXPLANATION } = window.KalendarEngine;

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

  // Days until the next major moment of the year, e.g. "17 days until Easter".
  // A faithful port of DayCard.countdownText: it measures the distance to the
  // dated anchors from this year and next, and reports the nearest one still ahead.
  function countdownText(day) {
    const start = day.date; // local midnight, matching the anchors
    const year = start.getFullYear();
    let nearest = null;

    for (const y of [year, year + 1]) {
      const keys = keyDates(y);
      const anchors = [
        ["Ash Wednesday", keys.ashWednesday],
        ["Easter", keys.easter],
        ["Pentecost", keys.pentecost],
        ["Advent", keys.adventStart],
        ["Christmas", keys.christmas],
      ];
      for (const [name, target] of anchors) {
        const days = daysBetween(start, target);
        if (days > 0 && days < (nearest ? nearest.days : Infinity)) {
          nearest = { name, days };
        }
      }
    }

    if (!nearest) return null;
    return nearest.days === 1
      ? `1 day until ${nearest.name}`
      : `${nearest.days} days until ${nearest.name}`;
  }

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
      ? "A solemnity is the highest rank of day in the church year. These mark the most important events of the faith, like Easter, Christmas, and Pentecost. They take priority over the regular season."
      : "Feasts and memorials mark people and events from the life of Jesus and the early church. A feast is the more important of the two; a memorial is a smaller remembrance.";

    const dayTitle = liturgicalDayTitle(day, day.date);
    const countdown = countdownText(day);

    panel.innerHTML = `
      <div class="panel-header">
        <div>
          <h2>${dateFormatter.format(day.date)} (${weekdayFormatter.format(day.date)})</h2>
          ${dayTitle ? `<div class="liturgical-day-title">${dayTitle}</div>` : ''}
          <div class="day-of-year">Day ${day.dayOfYear} of the year${countdown ? ` &middot; ${countdown}` : ''}</div>
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

      <div class="label">Color</div>
      <div class="swatch-row">
        <div class="swatch" style="background:${day.color.hex}; border-radius:50%;"></div>
        <strong>${day.color.name}</strong>
      </div>
      <p>${COLOR_EXPLANATION[day.color.key]}</p>

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
