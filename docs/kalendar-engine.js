/*
 * Kalendar liturgical engine: a faithful JS port of
 * kalendar/Models/LiturgicalCalendar.swift, for the read-only web demo.
 * Dates are plain local-time Date objects, always at midnight, compared by
 * calendar day rather than by exact millisecond, matching the Swift Calendar
 * based logic.
 */

const LiturgicalColor = {
  green:  { key: 'green',  name: 'Green',  hex: '#338C4D' },
  violet: { key: 'violet', name: 'Violet', hex: '#73338C' },
  white:  { key: 'white',  name: 'White',  hex: '#FFFFFF' },
  red:    { key: 'red',    name: 'Red',    hex: '#BF2626' },
  rose:   { key: 'rose',   name: 'Rose',   hex: '#D98099' },
};

// What each color signifies; mirrors LiturgicalColor.explanation in the Swift engine.
const COLOR_EXPLANATION = {
  green:  "Green stands for life and growth. It marks Ordinary Time, the long stretch of steady, everyday discipleship.",
  violet: "Violet stands for repentance and preparation. It marks Advent and Lent, the two seasons of waiting and turning back to God.",
  white:  "White stands for glory, purity, and celebration. It marks Christmas, Easter, and the great days that remember Jesus.",
  red:    "Red stands for blood and fire. It marks the suffering and death of Jesus, the coming of the Holy Spirit, and those who were killed for their faith.",
  rose:   "Rose is violet lightened with joy. It appears just twice a year, on the third Sunday of Advent and the fourth Sunday of Lent, a breath of encouragement partway through a season of waiting.",
};

const LiturgicalSeason = {
  advent:       'Advent',
  christmas:    'Christmas',
  ordinaryTime: 'Ordinary Time',
  lent:         'Lent',
  triduum:      'Triduum',
  easter:       'Easter',
};

const SEASON_EXPLANATION = {
  [LiturgicalSeason.advent]:
    "The four-week season of preparation and anticipation before Christmas. It centers on the coming of Jesus, both his birth and his promised return. The word 'Advent' means 'coming.'",
  [LiturgicalSeason.christmas]:
    "The joyful celebration of Jesus' birth, lasting from December 25 through the Baptism of the Lord in January. It is not just one day; the celebration continues for weeks.",
  [LiturgicalSeason.ordinaryTime]:
    "The longest season of the liturgical year, split into two stretches (after Christmas and after Pentecost). 'Ordinary' does not mean boring. It comes from 'ordinal' (counted). These weeks focus on Jesus' public life and teachings.",
  [LiturgicalSeason.lent]:
    "A 40-day season of prayer, fasting, and giving that prepares for Easter. It begins on Ash Wednesday and is a time for self-reflection and turning back toward God.",
  [LiturgicalSeason.triduum]:
    "The holiest three days of the entire liturgical year: Holy Thursday (Jesus' Last Supper), Good Friday (his crucifixion and death), and Holy Saturday (waiting at the tomb). It is the heart of the liturgical year.",
  [LiturgicalSeason.easter]:
    "The most important and joyful season, celebrating Jesus' resurrection from the dead. It lasts 50 days, from Easter Sunday all the way to Pentecost. It is treated as one long feast day.",
};

const SEASON_CONTEXTUAL_ITEMS = {
  [LiturgicalSeason.advent]: [
    "Light the Advent wreath candles week by week — three violet, one rose — marking time in a way that feels more honest than a countdown.",
    "Read Isaiah. The prophetic passages this season draws from are worth sitting with on their own.",
    "Keep a quiet morning or evening. Advent is a season of watching, and watching takes some stillness.",
    "The tone is expectant. The world is rushing toward Christmas; this season moves slower.",
  ],
  [LiturgicalSeason.christmas]: [
    "Keep celebrating past December 25. The season runs for weeks, and most people stop far too early.",
    "Read the opening of John's Gospel. It has been the Christmas reading for centuries, and it is not about a manger.",
    "Notice the days that cluster here: Stephen on the 26th, John on the 27th, the Holy Innocents on the 28th.",
    "The tone is warm and unhurried. Lent will come soon enough.",
  ],
  [LiturgicalSeason.ordinaryTime]: [
    "Follow the Sunday Gospel readings week by week, watching the ministry of Jesus unfold gradually.",
    "Notice the days that remember figures from Scripture as they come; many of them fall in this season.",
    "The tone is steady. This is the ordinary stretch, where most of the actual work of following happens.",
  ],
  [LiturgicalSeason.lent]: [
    "Consider a fast, and consider taking something on as well. The season is not only subtraction.",
    "Set aside time for prayer and honest self-examination. Lent is a turning back toward God.",
    "Read John chapters 11 through 19 before Holy Week arrives. Knowing them makes everything that follows land differently.",
    "The tone is serious but not without hope. Lent is pointing toward something.",
  ],
  [LiturgicalSeason.triduum]: [
    "These three days — Thursday, Friday, and the long wait of Saturday — are best kept together as one movement, not three separate days.",
    "Keep Holy Saturday quiet. The stillness before Easter is intentional.",
    "The tone moves from tenderness to grief to stillness to joy, in that order.",
  ],
  [LiturgicalSeason.easter]: [
    "Say Alleluia. It was held back all through Lent, and this is the season it belongs to.",
    "Read Acts of the Apostles from the beginning — the story of what happened after the resurrection, and it moves fast.",
    "The tone is joyful and sustained. Easter is not one day but fifty, longer than Lent.",
  ],
};

// MARK: date helpers (local-time calendar days)

function dateOnly(y, m, d) { return new Date(y, m - 1, d); }
function addDays(date, n) {
  const d = new Date(date);
  d.setDate(d.getDate() + n);
  return d;
}
function daysBetween(from, to) {
  const MS = 24 * 60 * 60 * 1000;
  const a = new Date(from.getFullYear(), from.getMonth(), from.getDate());
  const b = new Date(to.getFullYear(), to.getMonth(), to.getDate());
  return Math.round((b - a) / MS);
}
function sameDay(a, b) {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}
// JS getDay() is 0=Sunday..6=Saturday; Swift's `.weekday` component is
// 1=Sunday..7=Saturday. Only the "is it Sunday" check is ever needed here.
function isSundayDate(date) { return date.getDay() === 0; }
function monthOf(date) { return date.getMonth() + 1; }
function dayOf(date) { return date.getDate(); }
function yearOf(date) { return date.getFullYear(); }
// Swift-style weekday number (1=Sunday..7=Saturday), used only inside the
// Gaudete/Laetare and Lent week-offset math below to mirror the Swift source exactly.
function swiftWeekday(date) { return date.getDay() + 1; }

// MARK: Easter (Anonymous Gregorian Algorithm / Computus)

function easterDate(year) {
  const a = year % 19;
  const b = Math.floor(year / 100);
  const c = year % 100;
  const d = Math.floor(b / 4);
  const e = b % 4;
  const f = Math.floor((b + 8) / 25);
  const g = Math.floor((b - f + 1) / 3);
  const h = (19 * a + b - d - g + 15) % 30;
  const i = Math.floor(c / 4);
  const k = c % 4;
  const l = (32 + 2 * e + 2 * i - h - k) % 7;
  const m = Math.floor((a + 11 * h + 22 * l) / 451);
  const month = Math.floor((h + l - 7 * m + 114) / 31);
  const day = ((h + l - 7 * m + 114) % 31) + 1;
  return dateOnly(year, month, day);
}

// MARK: Key dates for a given year

function keyDates(year) {
  const easter = easterDate(year);

  const ashWednesday = addDays(easter, -46);
  const palmSunday = addDays(easter, -7);
  const holyThursday = addDays(easter, -3);
  const goodFriday = addDays(easter, -2);
  const holySaturday = addDays(easter, -1);
  const ascension = addDays(easter, 39);
  const pentecost = addDays(easter, 49);
  const trinitySunday = addDays(easter, 56);

  // Advent: starts on the Sunday closest to Nov 30 (4 Sundays before Christmas)
  const christmas = dateOnly(year, 12, 25);
  const christmasWeekday = swiftWeekday(christmas);
  const daysToSunday = (christmasWeekday === 1) ? 28 : (christmasWeekday - 1 + 21);
  const adventStart = addDays(christmas, -daysToSunday);

  const epiphany = dateOnly(year, 1, 6);
  // Baptism of the Lord: normally the Sunday after Epiphany. With Epiphany fixed
  // on Jan 6, if Jan 6 is itself a Sunday the Baptism is the following Sunday
  // (Jan 13), not the next day.
  const epiphanyWeekday = swiftWeekday(epiphany);
  const baptismOfLord = (epiphanyWeekday === 1)
    ? addDays(epiphany, 7)
    : addDays(epiphany, 8 - epiphanyWeekday);

  // Christ the King: last Sunday before Advent
  const christTheKing = addDays(adventStart, -7);

  return {
    easter, ashWednesday, palmSunday, holyThursday, goodFriday, holySaturday,
    ascension, pentecost, trinitySunday,
    adventStart, christmas, baptismOfLord, christTheKing,
  };
}

// MARK: Season determination

function seasonForDate(date, keys, prevYearKeys) {
  const year = yearOf(date);
  const janFirst = dateOnly(year, 1, 1);

  // Jan 1 to Baptism of the Lord: still Christmas season. (December dates are caught
  // by the `date >= keys.christmas` branch below; a date can never precede Jan 1 of
  // its own year, so no separate prev-year branch is needed.)
  if (date >= janFirst && date <= keys.baptismOfLord) return LiturgicalSeason.christmas;

  // Ordinary Time I: after Baptism of the Lord to Ash Wednesday
  if (date > keys.baptismOfLord && date < keys.ashWednesday) return LiturgicalSeason.ordinaryTime;

  // Lent: Ash Wednesday to Holy Thursday (exclusive of Triduum)
  if (date >= keys.ashWednesday && date < keys.holyThursday) return LiturgicalSeason.lent;

  // Triduum: Holy Thursday evening to Easter Sunday (inclusive)
  if (date >= keys.holyThursday && date <= keys.easter) return LiturgicalSeason.triduum;

  // Easter Season: Easter to Pentecost (inclusive)
  if (date > keys.easter && date <= keys.pentecost) return LiturgicalSeason.easter;

  // Advent
  if (date >= keys.adventStart && date < keys.christmas) return LiturgicalSeason.advent;

  // Christmas season (Dec 25 onward)
  if (date >= keys.christmas) return LiturgicalSeason.christmas;

  // Otherwise Ordinary Time II (after Pentecost to Advent)
  return LiturgicalSeason.ordinaryTime;
}

// MARK: Default liturgical color for a season

function defaultColorForSeason(season, isSunday, date, keys) {
  switch (season) {
    case LiturgicalSeason.advent: {
      if (isSunday) {
        const daysSinceAdvent = daysBetween(keys.adventStart, date);
        const sundayNumber = Math.floor(daysSinceAdvent / 7) + 1;
        if (sundayNumber === 3) return LiturgicalColor.rose;
      }
      return LiturgicalColor.violet;
    }
    case LiturgicalSeason.christmas:
      return LiturgicalColor.white;
    case LiturgicalSeason.lent: {
      if (isSunday) {
        const daysSinceLent = daysBetween(keys.ashWednesday, date);
        const ashWedWeekday = swiftWeekday(keys.ashWednesday);
        const daysToFirstSunday = (8 - ashWedWeekday) % 7;
        const firstSundayOffset = daysToFirstSunday === 0 ? 7 : daysToFirstSunday;
        if (daysSinceLent === firstSundayOffset + 21) return LiturgicalColor.rose;
      }
      return LiturgicalColor.violet;
    }
    case LiturgicalSeason.triduum:
      if (sameDay(date, keys.goodFriday)) return LiturgicalColor.red;
      return LiturgicalColor.white;
    case LiturgicalSeason.easter:
      return LiturgicalColor.white;
    case LiturgicalSeason.ordinaryTime:
      return LiturgicalColor.green;
    default:
      return LiturgicalColor.green;
  }
}

// MARK: Week of season

function weekOfSeason(date, season, keys) {
  switch (season) {
    case LiturgicalSeason.advent:
      return Math.floor(daysBetween(keys.adventStart, date) / 7) + 1;
    case LiturgicalSeason.lent: {
      const days = daysBetween(keys.ashWednesday, date);
      const ashWedWeekday = swiftWeekday(keys.ashWednesday);
      const daysToFirstSunday = (8 - ashWedWeekday) % 7;
      const adjusted = daysToFirstSunday === 0 ? 7 : daysToFirstSunday;
      if (days < adjusted) return 0;
      return Math.floor((days - adjusted) / 7) + 1;
    }
    case LiturgicalSeason.easter:
      return Math.floor(daysBetween(keys.easter, date) / 7) + 1;
    case LiturgicalSeason.ordinaryTime: {
      if (date > keys.baptismOfLord && date < keys.ashWednesday) {
        return Math.floor(daysBetween(keys.baptismOfLord, date) / 7) + 1;
      }
      // The second stretch is numbered backward from Christ the King,
      // which always begins Week 34, per the General Roman Calendar.
      const sunday = addDays(date, -date.getDay());
      return 34 - Math.floor(daysBetween(sunday, keys.christTheKing) / 7);
    }
    default:
      return null;
  }
}

// MARK: Feast precedence

function fixedFeastIsImpeded(date, season, isSunday, keys) {
  // Holy Week and the Triduum: Palm Sunday through Easter Sunday.
  if (date >= keys.palmSunday && date <= keys.easter) return true;

  // Octave of Easter: the eight days from Easter through the Second Sunday of Easter.
  const octaveEnd = addDays(keys.easter, 7);
  if (date > keys.easter && date <= octaveEnd) return true;

  // Privileged Sundays of Advent, Lent, and Easter outrank saints' days.
  if (isSunday && (season === LiturgicalSeason.advent || season === LiturgicalSeason.lent || season === LiturgicalSeason.easter)) return true;

  return false;
}

function transferTarget(natural, keys) {
  const month = monthOf(natural);
  const day = dayOf(natural);
  const inHolyWeekOrLater = natural >= keys.palmSunday;

  if (month === 3 && day === 25 && inHolyWeekOrLater) return addDays(keys.easter, 8);
  if (month === 3 && day === 19 && inHolyWeekOrLater) return addDays(keys.palmSunday, -1);
  return addDays(natural, 1);
}

function transferredSolemnity(date, keys, prevYearKeys) {
  const year = yearOf(date);
  const candidates = [dateOnly(year, 3, 19), dateOnly(year, 3, 25)];

  for (const natural of candidates) {
    const feast = fixedFeast(natural);
    if (!feast || !feast.solemnity) continue;
    const naturalSeason = seasonForDate(natural, keys, prevYearKeys);
    const naturalIsSunday = isSundayDate(natural);
    if (!fixedFeastIsImpeded(natural, naturalSeason, naturalIsSunday, keys)) continue;

    if (sameDay(date, transferTarget(natural, keys))) {
      return {
        ...feast,
        description: feast.description + " Its usual date was outranked this year, so it is observed today instead.",
      };
    }
  }
  return null;
}

// MARK: Fixed feasts (by month/day)

const FIXED_FEASTS = {
  '1-6':   { name: "Epiphany of the Lord", color: LiturgicalColor.white, solemnity: true,
    description: "Celebrates the visit of the Magi (Wise Men) to the infant Jesus. 'Epiphany' means 'revelation,' and this feast marks Jesus being revealed to the whole world, not just the Jewish people." },
  '1-25':  { name: "Conversion of Paul", color: LiturgicalColor.white, solemnity: false,
    description: "Recalls the dramatic moment when Saul of Tarsus, who was hunting down and imprisoning believers, was struck blind on the road to Damascus by a vision of the risen Jesus. He recovered, was baptized, changed his name to Paul, and became the greatest missionary the early Church ever produced." },
  '2-2':   { name: "Presentation of the Lord", color: LiturgicalColor.white, solemnity: false,
    description: "Forty days after Christmas, Mary and Joseph brought baby Jesus to the Temple in Jerusalem, as Jewish law required for firstborn sons. The elderly prophet Simeon recognized him as the Messiah and called him 'a light for revelation to the Gentiles.' Also called Candlemas." },
  '3-19':  { name: "Joseph, Husband of Mary", color: LiturgicalColor.white, solemnity: true,
    description: "Remembers Joseph, the earthly father of Jesus and husband of Mary. He was a carpenter from Nazareth who protected and raised Jesus, remembered for his quiet, faithful obedience." },
  '3-25':  { name: "Annunciation of the Lord", color: LiturgicalColor.white, solemnity: true,
    description: "Celebrates the moment the angel Gabriel appeared to Mary and announced she would conceive Jesus by the Holy Spirit. Mary said 'yes,' the moment believed to be when God became human. Exactly 9 months before Christmas." },
  '4-25':  { name: "Mark the Evangelist", color: LiturgicalColor.red, solemnity: false,
    description: "Honors Mark, the author of the shortest and most urgent of the four Gospels. He wrote it in Rome, likely drawing on Peter's eyewitness accounts, and his Gospel reads like it is in a hurry. The word 'immediately' appears over forty times." },
  '5-14':  { name: "Matthias the Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "Matthias was chosen by lot to replace Judas Iscariot among the twelve apostles. The account in Acts is brief. He is a reminder that the structure of the early community mattered enough to be filled, and that ordinary people were chosen for extraordinary roles." },
  '5-31':  { name: "The Visitation", color: LiturgicalColor.white, solemnity: false,
    description: "Celebrates Mary's journey to visit her cousin Elizabeth, who was pregnant with John the Baptist. When Mary arrived, Elizabeth's child leapt in her womb, and Elizabeth cried out 'Blessed are you among women.' Mary responded with the Magnificat, one of the most beautiful prayers in Scripture." },
  '6-11':  { name: "Barnabas the Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "Barnabas was not one of the original twelve but is called an apostle because of the scope of his missionary work. He was the one who vouched for Paul to the early community when everyone was afraid of him. He and Paul traveled together through Cyprus and Asia Minor, planting churches in city after city." },
  '6-24':  { name: "Nativity of John the Baptist", color: LiturgicalColor.white, solemnity: true,
    description: "The birth of John the Baptist, Jesus' cousin, who grew up to be the prophet who prepared the way for Jesus' ministry. He baptized people in the Jordan River and is the one who baptized Jesus himself." },
  '6-29':  { name: "Peter and Paul, Apostles", color: LiturgicalColor.red, solemnity: true,
    description: "Honors the two greatest apostles: Peter, the fisherman Jesus chose to lead his followers, and Paul, who started out persecuting believers but converted and became the greatest missionary of the early Church. Both were martyred in Rome." },
  '7-22':  { name: "Mary Magdalene", color: LiturgicalColor.white, solemnity: false,
    description: "Mary Magdalene was among Jesus' closest followers, present at his crucifixion when most of the apostles had fled, and the first person to see him after the resurrection. She is called the 'apostle to the apostles' because she carried the news of the resurrection to the others. Her feast was elevated to a proper feast in 2016." },
  '7-25':  { name: "James the Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "James was one of the sons of Zebedee and one of Jesus' inner circle of three, along with Peter and John. He was the first of the apostles to be martyred, killed by King Herod Agrippa around 44 AD. His shrine in Santiago de Compostela in Spain has been one of the great pilgrimage destinations for over a thousand years." },
  '8-6':   { name: "Transfiguration of the Lord", color: LiturgicalColor.white, solemnity: false,
    description: "Recalls when Jesus took three disciples up a mountain, and his appearance was transformed. His face shone like the sun and his clothes became dazzling white. Moses and Elijah appeared beside him, and God's voice said 'This is my beloved Son.'" },
  '9-21':  { name: "Matthew the Apostle and Evangelist", color: LiturgicalColor.red, solemnity: false,
    description: "Matthew was a tax collector, which made him a social outcast in his community. Jesus called him anyway. He went on to write the first of the four Gospels, the most Jewish in character, the one most concerned with showing how Jesus fulfills the Hebrew scriptures." },
  '10-18': { name: "Luke the Evangelist", color: LiturgicalColor.red, solemnity: false,
    description: "Luke was a physician and the only Gentile author in the New Testament. He wrote both the Gospel that bears his name and the Acts of the Apostles, together the longest single contribution to the New Testament. His Gospel is the one most attentive to women, the poor, and outsiders. He is the patron of doctors and artists." },
  '10-28': { name: "Simon and Jude, Apostles", color: LiturgicalColor.red, solemnity: false,
    description: "Two apostles honored together because little is known about either of them. Simon was called 'the Zealot,' probably indicating a political background. Jude (not Judas Iscariot) is traditionally linked to one of the short letters near the end of the New Testament." },
  '10-31': { name: "Reformation Day", color: LiturgicalColor.red, solemnity: false,
    description: "On October 31, 1517, Martin Luther is said to have posted his Ninety-Five Theses in Wittenberg, protesting abuses in the church of his day. The date became the marker of the Reformation, the movement that returned the Bible to the center of Christian life and gave rise to the Protestant and Reformed traditions." },
  '11-30': { name: "Andrew the Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "Andrew was Simon Peter's brother and, according to John's Gospel, the first of the apostles to follow Jesus. He brought Peter to Jesus. By tradition he was crucified on an X-shaped cross, which became his symbol." },
  '12-25': { name: "Nativity of the Lord (Christmas)", color: LiturgicalColor.white, solemnity: true,
    description: "The joyful celebration of Jesus' birth in Bethlehem. It marks the belief that God became a human baby, born to Mary in humble circumstances. It is one of the two greatest feasts of the liturgical year (along with Easter)." },
  '12-26': { name: "Stephen, the First Martyr", color: LiturgicalColor.red, solemnity: false,
    description: "Honors Stephen, one of the first deacons of the early Church, who became its very first martyr. He was stoned to death for his faith, and as he died he prayed for his persecutors, just as Jesus had done on the cross." },
  '12-27': { name: "John the Apostle and Evangelist", color: LiturgicalColor.white, solemnity: false,
    description: "Honors John, one of Jesus' closest disciples (the 'beloved disciple'), who is traditionally credited with writing the Gospel of John, three letters, and the Book of Revelation. He is the only apostle believed to have died of natural causes." },
  '12-28': { name: "Holy Innocents, Martyrs", color: LiturgicalColor.red, solemnity: false,
    description: "Remembers the infant boys of Bethlehem who were killed by King Herod in his attempt to destroy the newborn Jesus. They are considered the first martyrs for Christ, even though they were too young to know it." },
};

function fixedFeast(date) {
  return FIXED_FEASTS[`${monthOf(date)}-${dayOf(date)}`] || null;
}

// MARK: Movable feasts (relative to Easter)

function movableFeast(date, keys) {
  if (sameDay(date, keys.ashWednesday)) {
    return { name: "Ash Wednesday", color: LiturgicalColor.violet, solemnity: false,
      description: "The start of Lent. In many churches ashes are placed on the forehead in the shape of a cross, a sign of repentance and mortality that recalls the words 'Remember that you are dust, and to dust you shall return.' It is a day of fasting and reflection." };
  }
  if (sameDay(date, keys.palmSunday)) {
    return { name: "Palm Sunday of the Lord's Passion", color: LiturgicalColor.red, solemnity: false,
      description: "The last Sunday before Easter, marking Jesus' triumphant entry into Jerusalem when crowds waved palm branches and shouted 'Hosanna.' But the mood shifts as the long account of Jesus' suffering and death (the Passion) is also read. It begins Holy Week." };
  }
  if (sameDay(date, keys.holyThursday)) {
    return { name: "Holy Thursday", color: LiturgicalColor.white, solemnity: true,
      description: "Commemorates the Last Supper, when Jesus shared a final meal with his apostles, washed their feet as a sign of humble service, and gave them the bread and cup to remember him by. That night he was arrested in the Garden of Gethsemane." };
  }
  if (sameDay(date, keys.goodFriday)) {
    return { name: "Good Friday of the Lord's Passion", color: LiturgicalColor.red, solemnity: true,
      description: "The most solemn day of the year, when Christians remember Jesus' crucifixion and death. Services are stark and stripped down: Scripture readings, prayers, and reflection on the cross, often in bare surroundings. It is a day of solemn reflection and mourning." };
  }
  if (sameDay(date, keys.holySaturday)) {
    return { name: "Holy Saturday / Easter Vigil", color: LiturgicalColor.white, solemnity: true,
      description: "A day of quiet waiting at the tomb. The Easter Vigil on Saturday night is the most elaborate liturgy of the entire year: it begins in darkness with a blazing fire, traces salvation history through readings, and erupts in joy as Easter is proclaimed. New members are baptized into the faith." };
  }
  if (sameDay(date, keys.easter)) {
    return { name: "Easter Sunday of the Resurrection", color: LiturgicalColor.white, solemnity: true,
      description: "The most important day of the liturgical year, celebrating the core belief: that Jesus rose from the dead on the third day after his crucifixion, conquering death itself. 'He is risen.' The joy of this day extends for 50 days." };
  }
  const easterMonday = addDays(keys.easter, 1);
  if (sameDay(date, easterMonday)) {
    return { name: "Easter Monday", color: LiturgicalColor.white, solemnity: false,
      description: "The celebration of Easter continues. In many countries this is a public holiday. The Gospel tells of two disciples meeting the risen Jesus on the road to Emmaus without recognizing him at first." };
  }
  if (sameDay(date, keys.ascension)) {
    return { name: "Ascension of the Lord", color: LiturgicalColor.white, solemnity: true,
      description: "Forty days after Easter, Jesus ascended into heaven in the presence of his disciples, promising to send the Holy Spirit. His last words were a command: 'Go and make disciples of all nations.' This feast marks the completion of Jesus' earthly mission." };
  }
  if (sameDay(date, keys.pentecost)) {
    return { name: "Pentecost Sunday", color: LiturgicalColor.red, solemnity: true,
      description: "Fifty days after Easter, the Holy Spirit descended on the apostles like tongues of fire, giving them the courage and ability to preach in many languages. It is considered the 'birthday of the Church,' the moment the apostles went from hiding in fear to boldly proclaiming the Gospel. Red vestments represent the fire of the Spirit." };
  }
  if (sameDay(date, keys.trinitySunday)) {
    return { name: "Most Holy Trinity", color: LiturgicalColor.white, solemnity: true,
      description: "The Sunday after Pentecost, celebrating the central mystery of the faith: that God is one God in three persons, Father, Son, and Holy Spirit. It is not three gods, but one God experienced in three ways. Even theologians say it is a mystery beyond full human understanding." };
  }
  if (sameDay(date, keys.christTheKing)) {
    return { name: "Our Lord Jesus Christ, King of the Universe", color: LiturgicalColor.white, solemnity: true,
      description: "The last Sunday of the liturgical year, proclaiming Jesus as king, but not a worldly king with armies and palaces. His kingdom is one of truth, justice, love, and peace. The next week, the cycle starts all over again with Advent." };
  }
  return null;
}

// MARK: Liturgical day title (mirrors DayCard.liturgicalDayTitle in the Swift app)

// Numeric ordinal (e.g. "14th"), not spelled out: the date line already carries
// the weekday, so this title never repeats it and stays quick to parse.
function ordinalName(n) {
  const mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 13) return `${n}th`;
  switch (n % 10) {
    case 1: return `${n}st`;
    case 2: return `${n}nd`;
    case 3: return `${n}rd`;
    default: return `${n}th`;
  }
}

// The day's proper liturgical name (e.g. "2nd Week of Advent"), or null on feast
// days and in seasons without counted weeks. `info` is a liturgicalInfo() result;
// `date` supplies whether it's a Sunday. The weekday name itself is left out
// since the date line already shows it (e.g. "July 3, 2026 (Friday)").
function liturgicalDayTitle(info, date) {
  if (info.feastName != null || info.weekOfSeason == null) return null;

  const week = info.weekOfSeason;
  const isSunday = date.getDay() === 0;

  if (info.season === LiturgicalSeason.lent && week === 0) {
    // The days between Ash Wednesday and the First Sunday of Lent.
    return "After Ash Wednesday";
  }
  if (info.season === LiturgicalSeason.easter && week === 1 && !isSunday) {
    return "Octave of Easter";
  }

  switch (info.season) {
    case LiturgicalSeason.advent:
    case LiturgicalSeason.lent:
    case LiturgicalSeason.easter:
      return isSunday
        ? `${ordinalName(week)} Sunday of ${info.season}`
        : `${ordinalName(week)} Week of ${info.season}`;
    case LiturgicalSeason.ordinaryTime:
      return isSunday
        ? `${ordinalName(week)} Sunday in Ordinary Time`
        : `${ordinalName(week)} Week in Ordinary Time`;
    default:
      return null;
  }
}

// MARK: Civil holidays (secular U.S. observances, a layer beside the church year)

// The ordinal-th given weekday of a month. weekday: 0 = Sunday ... 6 = Saturday (JS getDay).
function nthWeekdayCivil(year, month, weekday, ordinal) {
  const firstDow = new Date(year, month - 1, 1).getDay();
  const offset = (weekday - firstDow + 7) % 7;
  return new Date(year, month - 1, 1 + offset + (ordinal - 1) * 7);
}
// The last given weekday of a month. weekday: 0 = Sunday ... 6 = Saturday.
function lastWeekdayCivil(year, month, weekday) {
  const last = new Date(year, month, 0); // day 0 of next month = last day of this month
  const diff = (last.getDay() - weekday + 7) % 7;
  return new Date(year, month - 1, last.getDate() - diff);
}

const FIXED_CIVIL_HOLIDAYS = {
  '1-1':   { name: "New Year's Day", description: "The first day of the civil year, and a federal holiday." },
  '2-14':  { name: "Valentine's Day", description: "A day associated with love and affection, named for an early Christian martyr." },
  '3-17':  { name: "St. Patrick's Day", description: "A cultural celebration of Irish heritage, on the traditional death date of the patron saint of Ireland." },
  '4-1':   { name: "April Fools' Day", description: "A day of pranks and hoaxes observed across many countries." },
  '4-22':  { name: "Earth Day", description: "An annual day of support for environmental protection, first held in 1970." },
  '5-5':   { name: "Cinco de Mayo", description: "A celebration of Mexican heritage, marking an 1862 Mexican victory at the Battle of Puebla." },
  '6-19':  { name: "Juneteenth", description: "A federal holiday marking the end of slavery in the United States in 1865." },
  '7-4':   { name: "Independence Day", description: "A federal holiday marking the adoption of the Declaration of Independence in 1776." },
  '10-31': { name: "Halloween", description: "The evening before All Hallows', now a cultural night of costumes and candy." },
  '11-11': { name: "Veterans Day", description: "A federal holiday honoring those who have served in the U.S. armed forces." },
  '12-24': { name: "Christmas Eve", description: "The evening before Christmas Day." },
  '12-31': { name: "New Year's Eve", description: "The last day of the civil year." },
};

// A secular U.S. holiday on `date`, if any. Mirrors civilHoliday(for:) in the Swift
// engine. Independent of the church year: never sets the color or rank, and can
// coexist with a feast. weekday numbers here are JS getDay values (0 = Sunday).
function civilHoliday(date) {
  const fixed = FIXED_CIVIL_HOLIDAYS[`${monthOf(date)}-${dayOf(date)}`];
  if (fixed) return fixed;

  const year = yearOf(date);
  const movable = [
    { name: "Martin Luther King Jr. Day", description: "A federal holiday honoring the civil-rights leader, on the third Monday of January.", target: nthWeekdayCivil(year, 1, 1, 3) },
    { name: "Presidents' Day", description: "A federal holiday (officially Washington's Birthday) on the third Monday of February.", target: nthWeekdayCivil(year, 2, 1, 3) },
    { name: "Mother's Day", description: "A day honoring mothers, on the second Sunday of May.", target: nthWeekdayCivil(year, 5, 0, 2) },
    { name: "Memorial Day", description: "A federal holiday honoring those who died in military service, on the last Monday of May.", target: lastWeekdayCivil(year, 5, 1) },
    { name: "Father's Day", description: "A day honoring fathers, on the third Sunday of June.", target: nthWeekdayCivil(year, 6, 0, 3) },
    { name: "Labor Day", description: "A federal holiday honoring the American worker, on the first Monday of September.", target: nthWeekdayCivil(year, 9, 1, 1) },
    { name: "Columbus Day", description: "A federal holiday on the second Monday of October, observed in some places as Indigenous Peoples' Day.", target: nthWeekdayCivil(year, 10, 1, 2) },
    { name: "Thanksgiving", description: "A federal holiday of gratitude and gathering, on the fourth Thursday of November.", target: nthWeekdayCivil(year, 11, 4, 4) },
  ];
  for (const h of movable) {
    if (sameDay(date, h.target)) return { name: h.name, description: h.description };
  }
  return null;
}

// MARK: Compute liturgical info for a date

function liturgicalInfo(date) {
  const year = yearOf(date);
  const keys = keyDates(year);
  const prevYearKeys = keyDates(year - 1);
  const isSunday = isSundayDate(date);
  const season = seasonForDate(date, keys, prevYearKeys);
  const civil = civilHoliday(date);
  const civilName = civil ? civil.name : null;
  const civilDescription = civil ? civil.description : null;

  const transferred = transferredSolemnity(date, keys, prevYearKeys);
  if (transferred) {
    return {
      season, color: transferred.color, feastName: transferred.name,
      feastDescription: transferred.description, isSolemnity: true, weekOfSeason: null,
      civilHolidayName: civilName, civilHolidayDescription: civilDescription,
    };
  }

  if (!fixedFeastIsImpeded(date, season, isSunday, keys)) {
    const feast = fixedFeast(date);
    if (feast) {
      return {
        season, color: feast.color, feastName: feast.name,
        feastDescription: feast.description, isSolemnity: feast.solemnity, weekOfSeason: null,
        civilHolidayName: civilName, civilHolidayDescription: civilDescription,
      };
    }
  }

  const movable = movableFeast(date, keys);
  if (movable) {
    return {
      season, color: movable.color, feastName: movable.name,
      feastDescription: movable.description, isSolemnity: movable.solemnity, weekOfSeason: null,
      civilHolidayName: civilName, civilHolidayDescription: civilDescription,
    };
  }

  const color = defaultColorForSeason(season, isSunday, date, keys);
  return {
    season, color, feastName: null, feastDescription: null,
    isSolemnity: false, weekOfSeason: weekOfSeason(date, season, keys),
    civilHolidayName: civilName, civilHolidayDescription: civilDescription,
  };
}

// Public surface used by browse.js
window.KalendarEngine = {
  LiturgicalColor,
  LiturgicalSeason,
  SEASON_EXPLANATION,
  SEASON_CONTEXTUAL_ITEMS,
  COLOR_EXPLANATION,
  liturgicalInfo,
  liturgicalDayTitle,
  keyDates,
  addDays,
  daysBetween,
  dateOnly,
};
