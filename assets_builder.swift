#!/usr/bin/env xcrun -sdk macosx swift

import Foundation
final class ResourceGenerator {

    fileprivate let formatterPath: String
    fileprivate let resourcePath: String
    fileprivate let basePath: String
    fileprivate let outputPath: String
    fileprivate var fm = FileManager.default
    fileprivate let builderFile: String
    fileprivate var fileName: String = "Assets.xcassets"
    fileprivate var bundleName: String = "Assets.bundle"

    init() {
        var arguments: [String] = CommandLine.arguments
        let dir = arguments.removeFirst() as NSString
        formatterPath = dir.deletingLastPathComponent + "/swiftformat"
        builderFile = dir.deletingLastPathComponent + "/assets_builder.swift"
        guard let p1 = arguments[safe: 0], let p2 = arguments[safe: 1] else {
            resourcePath = ""
            outputPath = ""
            basePath = ""
            assert(false, "not enough argument, resourcePath and outputPath ")
            return
        }
        fileName = (p1 as NSString).lastPathComponent
        basePath = (p1 as NSString).deletingLastPathComponent
        resourcePath = p1
        outputPath = p2
        if resourcePath == "" { return }
    }
}
// MARK: - Loop
extension ResourceGenerator {

    private func files(inDirectory dir: String) -> [String] {
        do { return try fm.contentsOfDirectory(atPath: dir) } catch { return [] }
    }

    private func path(isDirectory path: String) -> Bool {
        let isdir = false.unsafePointer
        if fm.fileExists(atPath: path, isDirectory: isdir) {
            return isdir.pointee.boolValue
        }
        return false
    }

    fileprivate func start() {
        let list = files(inDirectory: resourcePath)
        guard list.count > 0 else { writeOutput(of: ""); return }
        if resourcePath.hasSuffix(".xcassets") == false { return }
        let desc = loopDirectory(at: resourcePath, name: fileName, parent: "", isRoot: true)
        writeOutput(of: desc)
    }

    private func loopDirectory(at dirPath: String, name: String, parent: String, isRoot: Bool = false) -> String {
        var desc = ""
        let list = files(inDirectory: dirPath)
        guard list.count > 0 else { return desc }
        var sName = "\(removeSymbol(from: name).capitalized)"
        if isRoot {
          sName += "Image"
          bundleName = "\(sName).bundle"
        }
        desc = "\nstruct \(sName) {\n"
        if isRoot {
          desc += "/// if using this in framework project, change bundle to`\(bundleName).bundle = Bundle(for: <#YourClass#>.self)`\n"
          desc += "static var bundle: Bundle = Bundle.main\n"
        }
        var properties = ""
        var structs = ""
        let base = "\(parent)/\(name)"
        for item in list {
            if item == ".DS_Store" { continue }
            let p = basePath + base + "/" + item
            guard path(isDirectory: p) else { continue }
            if item.hasSuffix(".imageset") {
                let raw = item.replacingOccurrences(of: ".imageset", with: "")
                let name = raw.replacingOccurrences(of: " ", with: "_")
                properties += "static var \(name): UIImage { return UIImage(named: \"\(raw)\", in: \(bundleName), compatibleWith: nil)! }\n"
            } else if !item.hasSuffix(".appiconset") {
                let vname = varName(of: item)
                let subDesc = loopDirectory(at: p, name: vname, parent: base)
                structs += subDesc
            }
        }
        desc += properties + structs
        desc += "}\n"
        return desc
    }

    private func varName(of str: String) -> String {
        var name = ""
        var components = str.components(separatedBy: ".")
        if components.count < 2 { return str }
        let type = components.removeLast()
        let first = components.removeFirst()
        let firstPart = removeSymbol(from: first)
        let next = components.flatMap({ removeSymbol(from: $0).capitalized }).joined(separator: "")
        name = firstPart + next + type.capitalized
        return name
    }

    private func removeSymbol(from str: String) -> String {
        let pool: Set < String> = ["-", "(", ")", ".", "_"]
        var ret = ""
        var hasDealEver = false
        let t = str.trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: ".xcassets", with: "")

        var seps = Set<String>()
        for sep in pool {
            if t.contains(sep) {
                hasDealEver = true
                seps.insert(sep)
            }
        }
        if hasDealEver {
            var strTo = t
            for item in seps {
                let ar = strTo.components(separatedBy: item)
                strTo = ar.flatMap({ $0.capitalized }).joined(separator: "")
            }
            ret += strTo.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "Plus")
        } else {
            if str.characters.count > 0 {
                ret += t.capitalized.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "Plus")
            }
        }
        return ret
    }

}
// MARK: - output
private extension ResourceGenerator {

    func writeOutput(of content: String) {
        let header = "//  Resource\n//  Formated By swiftformat\n//  Created by LawLincoln \n//  Copyright © 2016年 LawLincoln. All rights reserved.\nimport UIKit"
        let total = header + content
        let data = total.data(using: String.Encoding.utf8)
        do {
            let url = URL(fileURLWithPath: outputPath)
            try data?.write(to: url, options: Data.WritingOptions.atomic)
            changePermission()
            formatCode(at: outputPath)
        } catch {}
    }

    func changePermission() {
        let task = Process()
        task.launchPath = "/bin/chmod"
        task.arguments = ["755", formatterPath]
        task.launch()
    }

    func formatCode(at path: String) {
        let task = Process()
        task.launchPath = formatterPath
        task.arguments = [path, "--indent", "4", path]
        task.launch()
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Bool {
    var unsafePointer: UnsafeMutablePointer<ObjCBool> {
        let b = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        b.initialize(to: ObjCBool(self))
        return b
    }
}
ResourceGenerator().start()
