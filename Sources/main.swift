import Foundation

for arg in CommandLine.arguments.dropFirst() {
    if let r = InputStream(fileAtPath: arg) {
        for line in r.lines() {
            print("xx>> [\(line)]")
        }
    }
}
