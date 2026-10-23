function daysInMonth(date) {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
}

function firstWeekday(date) {
    return (monthStart(date).getDay() + 6) % 7;
}

function isToday(date, today) {
    return date.getFullYear() === today.getFullYear() && date.getMonth() === today.getMonth() && date.getDate() === today.getDate();
}

function monthStart(date) {
    return new Date(date.getFullYear(), date.getMonth(), 1);
}

