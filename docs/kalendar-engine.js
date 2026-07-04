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

// Why each color is worn; mirrors LiturgicalColor.explanation in the Swift engine.
const COLOR_EXPLANATION = {
  green:  "Green is the color of life and growth. The priest wears it through Ordinary Time, the long stretch of steady, unhurried discipleship.",
  violet: "Violet is the color of penance and preparation. The priest wears it through Advent and Lent, the two seasons of waiting and turning back.",
  white:  "White is the color of glory, purity, and celebration. The priest wears it for Christmas, Easter, feasts of Jesus and Mary, and saints who were not martyred.",
  red:    "Red is the color of blood and fire. The priest wears it for the Passion of Jesus, for the Holy Spirit, and for the martyrs.",
  rose:   "Rose is violet lightened with joy. The priest wears it just twice a year, on Gaudete Sunday in Advent and Laetare Sunday in Lent, a breath of encouragement partway through a penitential season.",
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
    "Light the Advent wreath candles week by week. Three are violet, one is rose, and the progression marks time in a way that feels more honest than a countdown.",
    "Read Isaiah. The prophetic passages the liturgy draws from during these weeks are worth sitting with on their own, outside of Mass.",
    "Pray in the morning or the evening. Advent is a season of watching, and watching takes some quiet.",
    "The tone is expectant. The world is rushing toward Christmas. The liturgy is doing something slower.",
  ],
  [LiturgicalSeason.christmas]: [
    "Keep celebrating through January. Most people are done by December 26, which means missing the better half of the season.",
    "Read the prologue of John's Gospel. It is what the liturgy has called the Christmas reading for centuries, and it is not about a manger.",
    "Mark the feast days that cluster in these weeks: St. Stephen on the 26th, St. John on the 27th, the Holy Innocents on the 28th.",
    "The tone is warm and unhurried. Lent will come soon enough.",
  ],
  [LiturgicalSeason.ordinaryTime]: [
    "Follow the Sunday Gospel readings week by week. The three-year lectionary cycle moves through Matthew, Mark, and Luke in sequence, and tracking it lets you watch the ministry of Jesus unfold gradually.",
    "Pay attention to the saints' feasts as they come. Most of them fall in Ordinary Time, and they are the tradition's way of saying that holiness looks like something specific and concrete.",
    "The tone is steady. This is not the dramatic part of the year. It is the part where most of the actual work of following happens.",
  ],
  [LiturgicalSeason.lent]: [
    "Fast on Ash Wednesday and Good Friday. Abstain from meat on Fridays through the season.",
    "Take on one practice and give up one thing. The tradition is not only subtraction.",
    "Go to Stations of the Cross on a Friday. It is slower and older than a Sunday Mass and worth experiencing at least once in the season.",
    "Read John chapters 11 through 19 before Holy Week arrives. The liturgy moves through them and knowing them makes everything that follows land differently.",
    "The tone is serious without being without hope. Lent is pointing toward something.",
  ],
  [LiturgicalSeason.triduum]: [
    "Go to all three liturgies if you possibly can. Holy Thursday, Good Friday, and the Easter Vigil are not three separate services. They are one rite spread across three days.",
    "Keep Holy Saturday quiet. There is no liturgy until the Vigil, and the silence is intentional.",
    "Plan to stay for the full Easter Vigil. It takes hours, begins in darkness, and moves through a long sweep of readings before it erupts. That is the design, not the inconvenience.",
    "The Vigil is the night new members are baptized. If someone you know is entering the faith, this is when it happens.",
    "The tone goes from tenderness to grief to stillness to joy, in that order.",
  ],
  [LiturgicalSeason.easter]: [
    "Say Alleluia. It was held back all through Lent and this is the season it belongs to.",
    "Read Acts of the Apostles from the beginning. It is the season's companion text, the story of what happened after the resurrection, and it moves fast.",
    "Think about baptism. Easter Vigil is when new believers are received into the Church, and the whole season carries that sense of new life.",
    "The tone is joyful and sustained. Easter is not one day. It is fifty days, longer than Lent, and the tradition takes that seriously.",
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
  const corpusChristi = addDays(easter, 63);
  // Divine Mercy Sunday: the Second Sunday of Easter (octave day).
  const divineMercy = addDays(easter, 7);
  // Sacred Heart of Jesus: the Friday after Corpus Christi, 19 days after Pentecost.
  const sacredHeart = addDays(easter, 68);

  // Advent: starts on the Sunday closest to Nov 30 (4 Sundays before Christmas)
  const christmas = dateOnly(year, 12, 25);
  const christmasWeekday = swiftWeekday(christmas);
  const daysToSunday = (christmasWeekday === 1) ? 28 : (christmasWeekday - 1 + 21);
  const adventStart = addDays(christmas, -daysToSunday);

  // Holy Family: the Sunday within the Octave of Christmas. When Christmas itself
  // is a Sunday there is no Sunday between Dec 26 and 31, so the feast moves to
  // Dec 30 per the General Roman Calendar.
  const holyFamily = (christmasWeekday === 1)
    ? dateOnly(year, 12, 30)
    : addDays(christmas, 8 - christmasWeekday);

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
    ascension, pentecost, trinitySunday, corpusChristi, divineMercy, sacredHeart,
    adventStart, holyFamily, christmas, baptismOfLord, christTheKing,
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

  // Feasts of the Lord that land amid fixed feasts outrank a coincident saint's
  // day: the Holy Family (a Christmas-octave Sunday that can fall on St. Stephen,
  // St. John, or the Holy Innocents) and the Sacred Heart (a solemnity of the
  // Lord). In the rare year the Sacred Heart coincides with a fixed solemnity of
  // a saint, that saint is superseded rather than transferred.
  if (sameDay(date, keys.holyFamily)) return true;
  if (sameDay(date, keys.sacredHeart)) return true;

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
  '1-25':  { name: "Conversion of St. Paul", color: LiturgicalColor.white, solemnity: false,
    description: "Recalls the dramatic moment when Saul of Tarsus, who was hunting down and imprisoning believers, was struck blind on the road to Damascus by a vision of the risen Jesus. He recovered, was baptized, changed his name to Paul, and became the greatest missionary the early Church ever produced." },
  '2-2':   { name: "Presentation of the Lord", color: LiturgicalColor.white, solemnity: false,
    description: "Forty days after Christmas, Mary and Joseph brought baby Jesus to the Temple in Jerusalem, as Jewish law required for firstborn sons. The elderly prophet Simeon recognized him as the Messiah and called him 'a light for revelation to the Gentiles.' Also called Candlemas." },
  '2-22':  { name: "Chair of St. Peter", color: LiturgicalColor.white, solemnity: false,
    description: "Celebrates Peter's role as the leader of the apostles and the first bishop of Rome. The 'chair' is not a piece of furniture so much as a symbol of teaching authority. This feast is about the office of leadership that traces through every pope back to Peter." },
  '3-19':  { name: "St. Joseph, Spouse of the Blessed Virgin Mary", color: LiturgicalColor.white, solemnity: true,
    description: "Honors Joseph, the foster-father of Jesus and husband of Mary. He was a humble carpenter from Nazareth who protected and raised Jesus. He is the patron saint of workers, fathers, and the universal Church." },
  '3-25':  { name: "Annunciation of the Lord", color: LiturgicalColor.white, solemnity: true,
    description: "Celebrates the moment the angel Gabriel appeared to Mary and announced she would conceive Jesus by the Holy Spirit. Mary said 'yes,' the moment believed to be when God became human. Exactly 9 months before Christmas." },
  '4-25':  { name: "St. Mark, Evangelist", color: LiturgicalColor.red, solemnity: false,
    description: "Honors Mark, the author of the shortest and most urgent of the four Gospels. He wrote it in Rome, likely drawing on Peter's eyewitness accounts, and his Gospel reads like it is in a hurry. The word 'immediately' appears over forty times." },
  '5-1':   { name: "St. Joseph the Worker", color: LiturgicalColor.white, solemnity: false,
    description: "A feast established in 1955, celebrating Joseph as a model for all working people. It falls on May Day and is the tradition's answer to secular labor observances, offering a patron for the dignity and sanctity of ordinary work." },
  '5-14':  { name: "St. Matthias, Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "Matthias was chosen by lot to replace Judas Iscariot among the twelve apostles. The account in Acts is brief. He is a reminder that the structure of the early community mattered enough to be filled, and that ordinary people were chosen for extraordinary roles." },
  '5-31':  { name: "Visitation of the Blessed Virgin Mary", color: LiturgicalColor.white, solemnity: false,
    description: "Celebrates Mary's journey to visit her cousin Elizabeth, who was pregnant with John the Baptist. When Mary arrived, Elizabeth's child leapt in her womb, and Elizabeth cried out 'Blessed are you among women.' Mary responded with the Magnificat, one of the most beautiful prayers in Scripture." },
  '6-11':  { name: "St. Barnabas, Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "Barnabas was not one of the original twelve but is called an apostle because of the scope of his missionary work. He was the one who vouched for Paul to the early community when everyone was afraid of him. He and Paul traveled together through Cyprus and Asia Minor, planting churches in city after city." },
  '6-24':  { name: "Nativity of St. John the Baptist", color: LiturgicalColor.white, solemnity: true,
    description: "The birth of John the Baptist, Jesus' cousin, who grew up to be the prophet who prepared the way for Jesus' ministry. He baptized people in the Jordan River and is the one who baptized Jesus himself." },
  '6-29':  { name: "Sts. Peter and Paul, Apostles", color: LiturgicalColor.red, solemnity: true,
    description: "Honors the two greatest apostles: Peter, the fisherman Jesus chose to lead his followers (the first pope), and Paul, who started out persecuting believers but converted and became the greatest missionary of the early Church. Both were martyred in Rome." },
  '7-22':  { name: "St. Mary Magdalene", color: LiturgicalColor.white, solemnity: false,
    description: "Mary Magdalene was among Jesus' closest followers, present at his crucifixion when most of the apostles had fled, and the first person to see him after the resurrection. She is called the 'apostle to the apostles' because she carried the news of the resurrection to the others. Her feast was elevated to a proper feast in 2016." },
  '7-25':  { name: "St. James, Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "James was one of the sons of Zebedee and one of Jesus' inner circle of three, along with Peter and John. He was the first of the apostles to be martyred, killed by King Herod Agrippa around 44 AD. His shrine in Santiago de Compostela in Spain has been one of the great pilgrimage destinations for over a thousand years." },
  '8-6':   { name: "Transfiguration of the Lord", color: LiturgicalColor.white, solemnity: false,
    description: "Recalls when Jesus took three disciples up a mountain, and his appearance was transformed. His face shone like the sun and his clothes became dazzling white. Moses and Elijah appeared beside him, and God's voice said 'This is my beloved Son.'" },
  '8-10':  { name: "St. Lawrence, Deacon and Martyr", color: LiturgicalColor.red, solemnity: false,
    description: "Lawrence was one of the seven deacons of Rome under Pope Sixtus II. When Sixtus was martyred in 258, Lawrence was given three days to hand over the wealth of the community to the emperor. He spent the time distributing it to the poor, then presented the poor themselves as 'the treasure of the community.' He was executed on a gridiron. He is the patron of deacons, cooks, and the poor." },
  '9-14':  { name: "Exaltation of the Holy Cross", color: LiturgicalColor.red, solemnity: false,
    description: "Honors the cross on which Jesus was crucified. Rather than a symbol of defeat, it is seen as the instrument of salvation. This feast dates back to the 4th century when St. Helena (Emperor Constantine's mother) is believed to have found the actual cross in Jerusalem." },
  '9-21':  { name: "St. Matthew, Apostle and Evangelist", color: LiturgicalColor.red, solemnity: false,
    description: "Matthew was a tax collector, which made him a social outcast in his community. Jesus called him anyway. He went on to write the first of the four Gospels, the most Jewish in character, the one most concerned with showing how Jesus fulfills the Hebrew scriptures." },
  '9-29':  { name: "Sts. Michael, Gabriel, and Raphael, Archangels", color: LiturgicalColor.white, solemnity: false,
    description: "The only feast day dedicated to angels. Michael is the warrior archangel who leads the heavenly army against evil. Gabriel is the messenger who announced Jesus' birth to Mary. Raphael guided the young Tobias in the book of Tobit and is the patron of travelers and healing. Three names, three roles, one feast." },
  '10-1':  { name: "St. Thérèse of Lisieux, Doctor of the Church", color: LiturgicalColor.white, solemnity: false,
    description: "Thérèse Martin entered the Carmelite convent at fifteen and died of tuberculosis at twenty-four. She wrote an autobiography that became one of the most widely read spiritual books of the modern era. Her 'little way,' the conviction that small acts done with great love matter as much as grand gestures, made her a Doctor of the Church." },
  '10-2':  { name: "Guardian Angels", color: LiturgicalColor.white, solemnity: false,
    description: "A feast celebrating the belief that each person has an angel assigned to them for protection and guidance. The tradition is ancient, drawn from passages in the Psalms, the book of Daniel, and Jesus' own words about not despising 'one of these little ones, for their angels in heaven always see the face of my Father.'" },
  '10-4':  { name: "St. Francis of Assisi", color: LiturgicalColor.white, solemnity: false,
    description: "Francis of Assisi gave up a wealthy merchant's life in 13th-century Italy to live in radical poverty, preach the Gospel, and care for lepers. He founded the Franciscan order, received the stigmata (the wounds of Christ on his body), and wrote the Canticle of the Sun. He is the patron of animals, ecology, and Italy." },
  '10-18': { name: "St. Luke, Evangelist", color: LiturgicalColor.red, solemnity: false,
    description: "Luke was a physician and the only Gentile author in the New Testament. He wrote both the Gospel that bears his name and the Acts of the Apostles, together the longest single contribution to the New Testament. His Gospel is the one most attentive to women, the poor, and outsiders. He is the patron of doctors and artists." },
  '10-28': { name: "Sts. Simon and Jude, Apostles", color: LiturgicalColor.red, solemnity: false,
    description: "Two apostles honored together because little is known about either of them. Simon was called 'the Zealot,' probably indicating a political background. Jude (not Judas Iscariot) wrote one of the short letters near the end of the New Testament and is remembered, by long tradition, as the patron of lost causes." },
  '11-1':  { name: "All Saints", color: LiturgicalColor.white, solemnity: true,
    description: "A day to honor all saints, not just the famous ones with their own feast days, but every holy person in heaven, including ordinary people who lived faithful lives. It is a reminder that everyone is called to holiness." },
  '11-2':  { name: "All Souls' Day (Commemoration of All the Faithful Departed)", color: LiturgicalColor.violet, solemnity: false,
    description: "A day to remember all who have died, especially loved ones. It is a tender day of remembrance and mourning, often marked by visiting cemeteries and giving thanks for those who have gone before." },
  '11-9':  { name: "Dedication of the Lateran Basilica", color: LiturgicalColor.white, solemnity: false,
    description: "The Lateran Basilica in Rome is the cathedral of the bishop of Rome, which means it is technically the mother church of all Roman Catholics worldwide, outranking even St. Peter's. This feast, celebrating its dedication, is a way of marking unity with the broader Church." },
  '11-30': { name: "St. Andrew, Apostle", color: LiturgicalColor.red, solemnity: false,
    description: "Andrew was Simon Peter's brother and, according to John's Gospel, the first of the apostles to follow Jesus. He brought Peter to Jesus. He is said to have been crucified on an X-shaped cross, which became his symbol. He is the patron saint of Scotland, Greece, and Russia." },
  '12-25': { name: "Nativity of the Lord (Christmas)", color: LiturgicalColor.white, solemnity: true,
    description: "The joyful celebration of Jesus' birth in Bethlehem. It marks the belief that God became a human baby, born to Mary in humble circumstances. It is one of the two greatest feasts of the liturgical year (along with Easter)." },
  '12-26': { name: "St. Stephen, First Martyr", color: LiturgicalColor.red, solemnity: false,
    description: "Honors Stephen, one of the first deacons of the early Church, who became its very first martyr. He was stoned to death for his faith, and as he died he prayed for his persecutors, just as Jesus had done on the cross." },
  '12-27': { name: "St. John, Apostle and Evangelist", color: LiturgicalColor.white, solemnity: false,
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
      description: "The start of Lent. Ashes are placed on the forehead in the shape of a cross as a sign of repentance and mortality. The priest says 'Remember that you are dust, and to dust you shall return.' It is a day of fasting and reflection." };
  }
  if (sameDay(date, keys.palmSunday)) {
    return { name: "Palm Sunday of the Lord's Passion", color: LiturgicalColor.red, solemnity: false,
      description: "The last Sunday before Easter, marking Jesus' triumphant entry into Jerusalem when crowds waved palm branches and shouted 'Hosanna.' But the mood shifts as the long account of Jesus' suffering and death (the Passion) is also read. It begins Holy Week." };
  }
  if (sameDay(date, keys.holyThursday)) {
    return { name: "Holy Thursday", color: LiturgicalColor.white, solemnity: true,
      description: "Commemorates the Last Supper, when Jesus shared a final meal with his apostles, washed their feet as a sign of humble service, and instituted the Eucharist (communion). That night he was arrested in the Garden of Gethsemane." };
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
  if (sameDay(date, keys.divineMercy)) {
    return { name: "Divine Mercy Sunday", color: LiturgicalColor.white, solemnity: false,
      description: "The Second Sunday of Easter, named Divine Mercy Sunday by Pope John Paul II in the year 2000. Drawing on the writings of St. Faustina Kowalska, it dwells on God's mercy as the heart of the Easter mystery: the risen Jesus appearing to his disciples and giving them the power to forgive sins." };
  }
  if (sameDay(date, keys.sacredHeart)) {
    return { name: "Most Sacred Heart of Jesus", color: LiturgicalColor.white, solemnity: true,
      description: "A solemnity celebrating the love of Jesus for humanity, symbolized by his heart. It falls on the Friday after Corpus Christi, nineteen days after Pentecost. The devotion draws on the image of Christ's heart, pierced on the cross, as an unfailing source of mercy and compassion." };
  }
  if (sameDay(date, keys.holyFamily)) {
    return { name: "The Holy Family of Jesus, Mary, and Joseph", color: LiturgicalColor.white, solemnity: false,
      description: "Celebrated on the Sunday within the Octave of Christmas, this feast honors Jesus, Mary, and Joseph together as a household. It holds up the ordinary life of a family, with its work and its love, as something holy, and invites us to see our own homes in the same light." };
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
  if (sameDay(date, keys.corpusChristi)) {
    return { name: "Most Holy Body and Blood of Christ (Corpus Christi)", color: LiturgicalColor.white, solemnity: true,
      description: "A feast celebrating the Eucharist, the belief that bread and wine truly become the Body and Blood of Jesus during Mass. Many parishes hold outdoor processions carrying the Eucharist through the streets. 'Corpus Christi' is Latin for 'Body of Christ.'" };
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

// MARK: Compute liturgical info for a date

function liturgicalInfo(date) {
  const year = yearOf(date);
  const keys = keyDates(year);
  const prevYearKeys = keyDates(year - 1);
  const isSunday = isSundayDate(date);
  const season = seasonForDate(date, keys, prevYearKeys);

  const transferred = transferredSolemnity(date, keys, prevYearKeys);
  if (transferred) {
    return {
      season, color: transferred.color, feastName: transferred.name,
      feastDescription: transferred.description, isSolemnity: true, weekOfSeason: null,
    };
  }

  if (!fixedFeastIsImpeded(date, season, isSunday, keys)) {
    const feast = fixedFeast(date);
    if (feast) {
      return {
        season, color: feast.color, feastName: feast.name,
        feastDescription: feast.description, isSolemnity: feast.solemnity, weekOfSeason: null,
      };
    }
  }

  const movable = movableFeast(date, keys);
  if (movable) {
    return {
      season, color: movable.color, feastName: movable.name,
      feastDescription: movable.description, isSolemnity: movable.solemnity, weekOfSeason: null,
    };
  }

  const color = defaultColorForSeason(season, isSunday, date, keys);
  return {
    season, color, feastName: null, feastDescription: null,
    isSolemnity: false, weekOfSeason: weekOfSeason(date, season, keys),
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
