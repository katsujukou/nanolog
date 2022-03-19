interface BuildReportFile {
  [String]: { size: Number; };
}

interface BuildReport {
  totalBuildTime: Number;
  files: BuildReportFile
}