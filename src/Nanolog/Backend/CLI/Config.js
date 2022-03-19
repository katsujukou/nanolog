exports._importConfigJS = function (Left, Right, path) {
  try {
    return Right(require(path));
  }
  catch (e) {
    return Left(e);
  }
}