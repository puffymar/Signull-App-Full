import Foundation

struct SimilarityResult<T> {
    let item: T
    let score: Double // 0..1 (1 == identical)
}

func pickOrReroll<T>(
    maxRerolls: Int,
    threshold: Double,
    generate: @escaping () async throws -> T,
    similarity: @escaping (T) -> Double
) async throws -> T {
    var best: SimilarityResult<T>? = nil
    for _ in 0...maxRerolls {
        let candidate = try await generate()
        let s = similarity(candidate)
        if s < threshold { return candidate } // good enough
        if best == nil || s < best!.score { best = .init(item: candidate, score: s) }
    }
    // soften failure: accept least similar and log
    if let best { return best.item }
    throw SignullError.similarityExhausted
}

enum SignullError: Error {
    case similarityExhausted
}
