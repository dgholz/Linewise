import Foundation

protocol Linewise {
    associatedtype Seq : Sequence
    func lines() -> Seq
}

extension Linewise {
    func getLine(from: String?) -> (Range<String.Index>, Range<String.Index>)? {
        guard let maybeLine = from else { return nil }
        let lineStartIndex   = UnsafeMutablePointer<String.Index>.allocate(capacity: 1)
        let lineEndIndex     = UnsafeMutablePointer<String.Index>.allocate(capacity: 1)
        let contentsEndIndex = UnsafeMutablePointer<String.Index>.allocate(capacity: 1)
        let firstZeroLengthRange = maybeLine.startIndex..<maybeLine.startIndex
        maybeLine.getLineStart(lineStartIndex, end: lineEndIndex, contentsEnd: contentsEndIndex, for: firstZeroLengthRange)
        return (lineStartIndex.pointee..<contentsEndIndex.pointee, lineStartIndex.pointee..<lineEndIndex.pointee)
    }
}

extension InputStream : Linewise {

    func getLine(_ charsSeen: inout String?) -> String? {
        
        while hasBytesAvailable || charsSeen?.isEmpty != true {
           if let (lineContents, lineEnd) = getLine(from: charsSeen) {
                if lineEnd.upperBound != charsSeen!.endIndex || lineEnd != lineContents {
                    defer { charsSeen!.removeSubrange(lineEnd) }
                    return charsSeen!.substring(with: lineContents)
                }

            }
    
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
            let bytesRead = read(buffer, maxLength: 4096)
            if bytesRead > 0 {
                let newString = String.init(bytesNoCopy: buffer, length: bytesRead, encoding: .utf8, freeWhenDone: true)
                switch (charsSeen, newString) {
                    case (.none, .some):
                        charsSeen = newString
                    case (.some, .some):
                        charsSeen!.append(newString!)
                    default: break
                }
            } else {
                break
            }
        }
        self.close()
        guard let remaining = charsSeen, !remaining.isEmpty else { return nil }
        defer { charsSeen = nil }
        return remaining
    }

    func lines() -> UnfoldSequence<String, String?> {
        if self.streamStatus == .notOpen { 
             self.open()
        }
        let charsSeen: String? = nil
        return sequence(state: charsSeen, next: { (myState: inout String?) -> String? in
            return self.getLine(&myState)
        })
    }
}