import Foundation

enum SignullSchema {
    // Base64 for: { text: two short paragraphs (4–7 sentences total, first‑person present, no meta), choices[2] }
    static let twoParaChoicesB64 = """
eyJ0eXBlIjoib2JqZWN0IiwicHJvcGVydGllcyI6eyJ0ZXh0Ijp7InR5cGUiOiJzdHJpbmciLCJkZXNjcmlwdGlvbiI6IkV4YWN0bHkgdHdvIHNob3J0IHBhcmFncmFwaHMgKDQtNyBzZW50ZW5jZXMgdG90YWwpLiBGaXJzdC1wZXJzb24gcHJlc2VudC4gTm8gbWV0YS10ZXh0LiJ9LCJjaG9pY2VzIjp7InR5cGUiOiJhcnJheSIsIm1pbkl0ZW1zIjoyLCJtYXhJdGVtcyI6MiwiaXRlbXMiOnsidHlwZSI6Im9iamVjdCIsInByb3BlcnRpZXMiOnsibGFiZWwiOnsidHlwZSI6InN0cmluZyIsIm1heExlbmd0aCI6NjB9LCJoaW50Ijp7InR5cGUiOiJzdHJpbmciLCJtYXhMZW5ndGgiOjgwfX0sInJlcXVpcmVkIjpbImxhYmVsIiwiaGludCJdLCJhZGRpdGlvbmFsUHJvcGVydGllcyI6ZmFsc2V9fX0sInJlcXVpcmVkIjpbInRleHQiLCJjaG9pY2VzIl0sImFkZGl0aW9uYWxQcm9wZXJ0aWVzIjpmYWxzZX0=
"""

    static var twoParaChoicesJSON: String {
        guard let d = Data(base64Encoded: twoParaChoicesB64),
              let s = String(data: d, encoding: .utf8) else { return "{}" }
        return s
    }
}


