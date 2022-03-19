const dayjs = require('dayjs');

const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');

// タイムゾーン拡張し日本時間をデフォルトにする
dayjs.extend(utc);
dayjs.extend(timezone);
dayjs.tz.setDefault("Asia/Tokyo")

exports._toUnix = function (datetime) {
  return datetime.unix();
}

exports._toUnixMilliseconds = function (datetime) {
  return datetime.valueOf();
}

exports._now = function () {
  return _ => dayjs();
}

exports._format = function (format, datetime) {
  return datetime.tz().format(format);
}

exports._parseFormat = function (Nothing, Just, format, strict, string) {
  const dt = dayjs(string, format, strict);
  return dt.isValid() ? Just(dt) : Nothing;
}

exports._fromForeign = function (Nothing, Just, f) {
  try {
    const dt = dayjs(f);
    return dt.isValid() ? Just(dt) : Nothing;
  }
  catch (_) {
    return Nothing;
  }
}
/**
 * 
 * @param {dayjs.Dayjs} dt 
 */
exports._toJSDate = function (dt) {
  return dt.toDate();
}