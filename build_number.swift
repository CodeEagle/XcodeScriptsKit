#!/usr/bin/env xcrun -sdk macosx swift

import Foundation

func addBuildNumber() {
    let buildKey = "CFBundleVersion"
    let totalKey = "total"
    var arguments: [String] = CommandLine.arguments
    let dir = arguments.removeFirst() as NSString
    let buildInfo = arguments.removeFirst()
    let infoPlistpath = arguments.removeFirst()
    var userInfo: [String : Any] = [:]
    if let info = NSDictionary(contentsOfFile: buildInfo) as? [String : Any] { userInfo = info }
    let array = dir.components(separatedBy: "/")
    let userName = array[2]
    let release = arguments.removeLast() == "1"
    var count = userInfo[userName] as? Int ?? 0
    count += 1
    userInfo[userName] = count
    var total = userInfo[totalKey] as? Int ?? 0
    total += 1
    userInfo[totalKey] = total
    _ = (userInfo as NSDictionary).write(toFile: buildInfo, atomically: true)
    if release {
        guard let info = NSDictionary(contentsOfFile: infoPlistpath) as? [String : Any] else { return }
        var f = info
        f[buildKey] = "\(total)"
        _ = (f as NSDictionary).write(toFile: infoPlistpath, atomically: true)
    }
}
addBuildNumber()
