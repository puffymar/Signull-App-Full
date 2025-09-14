import Foundation

func continueScene(context: StoryData, playerInput: String) async throws -> String {
    let ws = WorldStore.shared.state
    let npcs = WorldStore.shared.npcs
    _ = """
    You are SIGNULL. Continue the scene in-world, in the same voice. Output story paragraphs only; no prefaces or meta.
    """
    let user = PromptComposer().continueUserPrompt(context: context, ws: ws, npcs: npcs, playerInput: playerInput)

    // Route through the single client so headers/endpoint are consistent:
    let storyData = try await SignullAPI.generateStory(
        prompt: user,
        onPhase: { _ in }, 
        onIntensity: { _ in }
    )
    return storyData.fullStory
} 