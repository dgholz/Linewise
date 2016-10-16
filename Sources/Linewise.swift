import Foundation

protocol Linewise {
    associatedtype Seq : Sequence
    func lines() -> Seq
}

extension String {
    func getLine(startingAt: String.Index? = nil) -> (Range<String.Index>, Range<String.Index>) {
        var lineStartIndex           = self.startIndex
        var lineEndIndex             = self.startIndex
        var contentsEndIndex         = self.startIndex
        let firstIndex = startingAt ?? self.startIndex
        let firstZeroLengthRange = firstIndex..<firstIndex
        getLineStart(&lineStartIndex, end: &lineEndIndex, contentsEnd: &contentsEndIndex, for: firstZeroLengthRange)
        if lineStartIndex < firstIndex { lineStartIndex = firstIndex }
        return (lineStartIndex..<contentsEndIndex, lineStartIndex..<lineEndIndex)
    }
}

extension InputStream : Linewise {

    func getLine(_ charsSeen: inout String?) -> String? {
        
        while hasBytesAvailable || charsSeen?.isEmpty != true {
           if let (lineContents, lineEnd) = charsSeen?.getLine() {
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
        return sequence(state: nil, next: { (charsSeen: inout String?) -> String? in
            return self.getLine(&charsSeen)
        })
    }
}

extension String : Linewise {
    func lines() -> UnfoldSequence<String, String.Index> {
        return sequence(state: self.startIndex, next: { (consumedUpTo: inout String.Index) -> String? in
            guard consumedUpTo != self.endIndex else { return nil }
            let (lineContents, lineEnd) = self.getLine(startingAt: consumedUpTo)
            defer { consumedUpTo = lineEnd.upperBound }
            return self.substring(with: lineContents)
        })
    }
}
