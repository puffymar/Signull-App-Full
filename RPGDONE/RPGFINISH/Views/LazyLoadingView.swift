import SwiftUI
import Combine

// MARK: - Lazy Loading View
struct LazyLoadingView<Content: View, Placeholder: View>: View {
    let content: () -> Content
    let placeholder: () -> Placeholder
    let loadTrigger: LazyLoadTrigger
    let onLoad: (() -> Void)?
    
    @State private var isLoaded = false
    @State private var isLoading = false
    @State private var loadTask: AnyCancellable?
    
    init(
        loadTrigger: LazyLoadTrigger = .immediate,
        onLoad: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.loadTrigger = loadTrigger
        self.onLoad = onLoad
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if isLoaded {
                content()
            } else {
                placeholder()
                    .onAppear {
                        triggerLoad()
                    }
            }
        }
        .onReceive(loadTrigger.publisher) { _ in
            triggerLoad()
        }
    }
    
    private func triggerLoad() {
        guard !isLoaded && !isLoading else { return }
        
        isLoading = true
        
        // Simulate loading delay for better UX
        loadTask = Just(())
            .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { _ in
                isLoaded = true
                isLoading = false
                onLoad?()
            }
    }
}

// MARK: - Lazy Load Trigger
enum LazyLoadTrigger {
    case immediate
    case delayed(TimeInterval)
    case custom(AnyPublisher<Void, Never>)
    
    var publisher: AnyPublisher<Void, Never> {
        switch self {
        case .immediate:
            return Just(()).eraseToAnyPublisher()
        case .delayed(let delay):
            return Just(())
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        case .custom(let publisher):
            return publisher
        }
    }
}

// MARK: - Lazy Loading List
struct LazyLoadingList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let content: (Data.Element) -> Content
    let loadMoreTrigger: LazyLoadTrigger
    let onLoadMore: (() -> Void)?
    
    @State private var visibleItems: Set<Data.Element.ID> = []
    @State private var loadMoreTask: AnyCancellable?
    
    init(
        data: Data,
        loadMoreTrigger: LazyLoadTrigger = .delayed(0.5),
        onLoadMore: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.loadMoreTrigger = loadMoreTrigger
        self.onLoadMore = onLoadMore
        self.content = content
    }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                LazyLoadingView(
                    loadTrigger: .delayed(Double(index) * 0.1),
                    onLoad: {
                        visibleItems.insert(item.id)
                        checkLoadMore(index: index)
                    }
                ) {
                    content(item)
                } placeholder: {
                    LazyLoadingPlaceholder()
                }
            }
        }
    }
    
    private func checkLoadMore(index: Int) {
        let threshold = data.count - 3 // Load more when 3 items from end
        
        if index >= threshold {
            loadMoreTask?.cancel()
            loadMoreTask = loadMoreTrigger.publisher
                .sink { _ in
                    onLoadMore?()
                }
        }
    }
}

// MARK: - Lazy Loading Placeholder
struct LazyLoadingPlaceholder: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 60)
            .overlay(
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 20, height: 20)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 120, height: 12)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Lazy Loading Image
struct LazyLoadingImage: View {
    let url: URL?
    let placeholder: String
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var loadTask: AnyCancellable?
    
    init(
        url: URL?,
        placeholder: String = "photo",
        contentMode: ContentMode = .fit
    ) {
        self.url = url
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Image(systemName: placeholder)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .foregroundColor(.gray)
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .overlay(
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
        )
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        
        loadTask = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { loadedImage in
                self.image = loadedImage
                self.isLoading = false
            }
    }
}

// MARK: - Lazy Loading Text
struct LazyLoadingText: View {
    let text: String
    let font: Font
    let color: Color
    let loadTrigger: LazyLoadTrigger
    
    @State private var isLoaded = false
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var typewriterTimer: Timer?
    
    init(
        text: String,
        font: Font = .body,
        color: Color = .primary,
        loadTrigger: LazyLoadTrigger = .immediate
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.loadTrigger = loadTrigger
    }
    
    var body: some View {
        Text(displayedText)
            .font(font)
            .foregroundColor(color)
            .onReceive(loadTrigger.publisher) { _ in
                startTypewriterEffect()
            }
    }
    
    private func startTypewriterEffect() {
        guard !isLoaded else { return }
        
        isLoaded = true
        currentIndex = 0
        displayedText = ""
        
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText += String(text[index])
                currentIndex += 1
            } else {
                timer.invalidate()
                typewriterTimer = nil
            }
        }
    }
}

// MARK: - Lazy Loading Grid
struct LazyLoadingGrid<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let columns: [GridItem]
    let content: (Data.Element) -> Content
    let loadMoreTrigger: LazyLoadTrigger
    let onLoadMore: (() -> Void)?
    
    @State private var visibleItems: Set<Data.Element.ID> = []
    
    init(
        data: Data,
        columns: [GridItem] = [GridItem(.adaptive(minimum: 150))],
        loadMoreTrigger: LazyLoadTrigger = .delayed(0.5),
        onLoadMore: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.columns = columns
        self.loadMoreTrigger = loadMoreTrigger
        self.onLoadMore = onLoadMore
        self.content = content
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                LazyLoadingView(
                    loadTrigger: .delayed(Double(index) * 0.1),
                    onLoad: {
                        visibleItems.insert(item.id)
                        checkLoadMore(index: index)
                    }
                ) {
                    content(item)
                } placeholder: {
                    LazyLoadingPlaceholder()
                        .frame(height: 120)
                }
            }
        }
    }
    
    private func checkLoadMore(index: Int) {
        let threshold = data.count - 6 // Load more when 6 items from end
        
        if index >= threshold {
            onLoadMore?()
        }
    }
}

// MARK: - Preload Manager
class PreloadManager: ObservableObject {
    static let shared = PreloadManager()
    
    private var preloadQueue = DispatchQueue(label: "com.rpgfinish.preload", qos: .background)
    private var preloadTasks: [String: AnyCancellable] = [:]
    
    func preloadContent<T>(_ content: T, for key: String) {
        preloadTasks[key]?.cancel()
        
        preloadTasks[key] = Just(content)
            .delay(for: .milliseconds(100), scheduler: preloadQueue)
            .sink { _ in
                // Content is now preloaded
                print("✅ Preloaded content for key: \(key)")
            }
    }
    
    func cancelPreload(for key: String) {
        preloadTasks[key]?.cancel()
        preloadTasks.removeValue(forKey: key)
    }
    
    func cancelAllPreloads() {
        preloadTasks.values.forEach { $0.cancel() }
        preloadTasks.removeAll()
    }
} 