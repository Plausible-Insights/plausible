// https://stackoverflow.com/a/50130338
export function formatISO(date) {
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
}

export function shiftMonths(date, months) {
  const newDate = new Date(date.getTime())
  newDate.setMonth(newDate.getMonth() + months)
  return newDate
}

export function shiftDays(date, days) {
  const newDate = new Date(date.getTime())
  newDate.setDate(newDate.getDate() + days)
  return newDate
}

const MONTHS = [
  "January", "February", "March",
  "April", "May", "June", "July",
  "August", "September", "October",
  "November", "December"
]

export function formatMonthYYYY(date) {
  return `${MONTHS[date.getMonth()]} ${date.getFullYear()}`;
}

export function formatMonth(date) {
  return `${MONTHS[date.getMonth()]}`;
}

export function formatDay(date) {
  return `${date.getDate()} ${formatMonth(date)}`;
}

// https://stackoverflow.com/a/11124448
export function newDateInOffset(offset) {
  return new Date(new Date().getTime() + offset * 1000)
}

export function isToday(site, date) {
  return formatISO(date) === formatISO(newDateInOffset(site.offset))
}
