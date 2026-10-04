func notesPlainTextBody(title: String, fullText: String?, nativeBody: String) -> String {
  guard !title.isEmpty, let fullText else { return nativeBody }
  if fullText.utf8.elementsEqual(nativeBody.utf8) {
    if fullText.utf8.elementsEqual(title.utf8) { return "" }
    let prefix = title + "\n"
    if fullText.utf8.starts(with: prefix.utf8) { return String(fullText.dropFirst(prefix.count)) }
  }
  guard fullText.utf8.elementsEqual((title + nativeBody).utf8) else { return nativeBody }
  // The native title-less projection can retain the title's LF terminator.
  guard nativeBody.hasPrefix("\n") else { return nativeBody }
  return String(nativeBody.dropFirst())
}
