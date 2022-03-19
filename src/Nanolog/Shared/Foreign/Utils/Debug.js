exports._debugLog = function (a) {
  return () => {
    console.log(a)
  }
}