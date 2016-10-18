#!/usr/bin/env xcrun -sdk macosx swift

import Foundation
extension Bool {
    var unsafePointer: UnsafeMutablePointer<ObjCBool> {
        let b = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        b.initialize(to: ObjCBool(self))
        return b
    }
}
func files(inDirectory dir: String) -> [String] {
    let fm = FileManager.default
    do { return try fm.contentsOfDirectory(atPath: dir) } catch { return [] }
}
private func path(isDirectory path: String) -> Bool {
    let isdir = false.unsafePointer
    let fm = FileManager.default
    if fm.fileExists(atPath: path, isDirectory: isdir) {
        return isdir.pointee.boolValue
    }
    return false
}

func loop(at folder: String) {
  var arguments: [String] = CommandLine.arguments
  let dir = arguments.removeFirst() as NSString
  let formatterPath = dir.deletingLastPathComponent + "/swiftformat"
  let contents = files(inDirectory: folder)
  for item in contents {
    if item == ".DS_Store" { continue }
    let itemPath = folder + "/\(item)"
    if path(isDirectory: itemPath) {
      loop(at: itemPath)
    } else if item.hasSuffix(".swift") {
      formatCode(at: itemPath, exePath: formatterPath)
    }
  }
}

func formatCode(at path: String, exePath: String) {
    let task = Process()
    task.launchPath = exePath
    task.arguments = [path, "-i", "4", path]
    task.launch()
}

func start() {
    var arguments: [String] = CommandLine.arguments
    arguments.removeFirst()
    let targetFolder = arguments.removeFirst()
    loop(at: targetFolder)
}

start()
