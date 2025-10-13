//
//  ArticleService.swift
//  CognityPin
//
//  Created by Вячеслав on 10/13/25.
//

import Foundation
import Combine

class ArticleService: ObservableObject {
    @Published var articles: [Article] = []
    @Published var featuredArticles: [Article] = []
    @Published var quizQuestions: [QuizQuestion] = []
    
    private let userDefaults = UserDefaults.standard
    private let articlesKey = "SavedArticles"
    private let questionsKey = "SavedQuestions"
    
    init() {
        loadSampleData()
        loadSavedData()
    }
    
    // MARK: - Public Methods
    
    func getArticles(for category: ArticleCategory? = nil) -> [Article] {
        if let category = category {
            return articles.filter { $0.category == category }
        }
        return articles
    }
    
    func searchArticles(query: String) -> [Article] {
        guard !query.isEmpty else { return articles }
        
        return articles.filter { article in
            article.title.localizedCaseInsensitiveContains(query) ||
            article.content.localizedCaseInsensitiveContains(query) ||
            article.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func getHealthRelatedArticles() -> [Article] {
        return articles.filter { $0.healthRelated }
    }
    
    func getQuizQuestions(for articleId: UUID) -> [QuizQuestion] {
        return quizQuestions.filter { $0.articleId == articleId }
    }
    
    func toggleBookmark(for article: Article) {
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            articles[index] = Article(
                title: article.title,
                content: article.content,
                category: article.category,
                readingTime: article.readingTime,
                tags: article.tags,
                isBookmarked: !article.isBookmarked,
                difficulty: article.difficulty,
                healthRelated: article.healthRelated,
                imageURL: article.imageURL
            )
            saveData()
        }
    }
    
    func getBookmarkedArticles() -> [Article] {
        return articles.filter { $0.isBookmarked }
    }
    
    // MARK: - Private Methods
    
    private func loadSampleData() {
        // Health Articles
        let healthArticles = [
            Article(
                title: "Understanding Heart Rate Variability",
                content: """
                Heart Rate Variability (HRV) is a measure of the variation in time between each heartbeat. This variation is controlled by a primitive part of the nervous system called the autonomic nervous system (ANS). It works behind the scenes, automatically regulating our heart rate, blood pressure, breathing, and digestion among other key tasks.
                
                The ANS is subdivided into two large components, the sympathetic and the parasympathetic nervous system, also known as the fight-or-flight mechanism and the relaxation response. The brain is constantly processing information in a region called the hypothalamus. The hypothalamus, through the ANS, sends signals to the rest of the body either to stimulate or to relax different functions.
                
                When we have a healthy balance between the sympathetic and parasympathetic branches of our ANS, our HRV reflects this balance in its variability. Simply put, the healthier the ANS the faster you are able to switch gears, showing more resilience and flexibility. Over the past few decades, research has shown a relationship between low HRV and worsening depression or anxiety. A low HRV is even associated with an increased risk of death and cardiovascular disease.
                
                People who have a high HRV may have greater cardiovascular fitness and be more resilient to stress. HRV may also provide personal feedback about your lifestyle and help motivate those who are considering taking steps toward a healthier life. It is fascinating to see how HRV changes as you incorporate more mindfulness, meditation, sleep, and especially physical activity into your life.
                """,
                category: .health,
                readingTime: 5,
                tags: ["heart rate", "cardiovascular", "stress", "wellness"],
                difficulty: .intermediate,
                healthRelated: true
            ),
            Article(
                title: "The Science of Sleep Cycles",
                content: """
                Sleep is not a uniform state of rest, but rather a complex, cyclical process that our bodies go through multiple times each night. Understanding these sleep cycles can help you optimize your rest and wake up feeling more refreshed.
                
                A typical sleep cycle lasts about 90-110 minutes and consists of several stages:
                
                Stage 1 (Light Sleep): This is the transition between wakefulness and sleep. Your muscles relax, your heart rate and breathing slow down, and your brain waves begin to change from the alpha waves of relaxed wakefulness to the theta waves of light sleep.
                
                Stage 2 (Light Sleep): This stage makes up about 45% of your total sleep time. Your body temperature drops, your heart rate continues to slow, and your brain produces sleep spindles and K-complexes - brief bursts of brain activity that help keep you asleep.
                
                Stage 3 (Deep Sleep): Also known as slow-wave sleep or delta sleep, this is the most restorative stage. Your brain produces slow delta waves, your muscles are completely relaxed, and your body repairs tissues, builds bone and muscle, and strengthens the immune system.
                
                REM Sleep: Rapid Eye Movement sleep is when most vivid dreaming occurs. Your brain is highly active, almost as active as when you're awake. This stage is crucial for memory consolidation, emotional processing, and brain development.
                
                Most people go through 4-6 complete sleep cycles per night. The proportion of each stage changes throughout the night - you get more deep sleep in the first half of the night and more REM sleep in the second half.
                """,
                category: .health,
                readingTime: 4,
                tags: ["sleep", "cycles", "REM", "recovery"],
                difficulty: .beginner,
                healthRelated: true
            )
        ]
        
        // Science Articles
        let scienceArticles = [
            Article(
                title: "Quantum Entanglement Explained",
                content: """
                Quantum entanglement is one of the most fascinating and counterintuitive phenomena in physics. Albert Einstein famously called it "spooky action at a distance" because he was uncomfortable with its implications for our understanding of reality.
                
                When two particles become entangled, they form a connected system where the quantum state of each particle cannot be described independently. Instead, they exist in a superposition of states until measured. What makes this truly remarkable is that when you measure one particle and determine its state, you instantly know the state of its entangled partner, regardless of how far apart they are.
                
                This instantaneous correlation seems to violate the principle that nothing can travel faster than light. However, no information is actually transmitted between the particles. Instead, the measurement of one particle affects the probability of finding the other particle in a particular state.
                
                Quantum entanglement has been experimentally verified countless times and forms the basis for emerging technologies like quantum computing, quantum cryptography, and quantum teleportation. In quantum computing, entangled qubits can perform certain calculations exponentially faster than classical computers.
                
                The phenomenon challenges our classical intuitions about locality and realism, suggesting that the universe is fundamentally interconnected in ways we're only beginning to understand.
                """,
                category: .science,
                readingTime: 6,
                tags: ["quantum", "physics", "entanglement", "computing"],
                difficulty: .advanced,
                healthRelated: false
            )
        ]
        
        // Technology Articles
        let technologyArticles = [
            Article(
                title: "The Future of Artificial Intelligence",
                content: """
                Artificial Intelligence (AI) has evolved from science fiction to an integral part of our daily lives. From the recommendation algorithms on streaming platforms to the voice assistants in our phones, AI is reshaping how we interact with technology.
                
                Current AI systems excel at specific tasks - they can recognize images, translate languages, play complex games, and even generate human-like text. However, these systems are examples of "narrow AI" - they're designed for specific applications and can't generalize their knowledge to other domains.
                
                The next frontier is Artificial General Intelligence (AGI) - AI systems that can understand, learn, and apply knowledge across a wide range of tasks, much like human intelligence. While we're still years away from achieving AGI, researchers are making significant progress in areas like:
                
                Machine Learning: Algorithms that can learn and improve from experience without being explicitly programmed for every scenario.
                
                Neural Networks: Computing systems inspired by biological neural networks that can recognize patterns and make decisions.
                
                Natural Language Processing: AI's ability to understand and generate human language, enabling more natural human-computer interactions.
                
                Computer Vision: AI systems that can interpret and understand visual information from the world around them.
                
                The implications of advanced AI are profound, potentially revolutionizing fields like healthcare, education, transportation, and scientific research while also raising important questions about ethics, employment, and the future of human society.
                """,
                category: .technology,
                readingTime: 7,
                tags: ["AI", "machine learning", "future", "innovation"],
                difficulty: .intermediate,
                healthRelated: false
            )
        ]
        
        // Psychology Articles
        let psychologyArticles = [
            Article(
                title: "The Psychology of Habit Formation",
                content: """
                Habits are the invisible architecture of daily life. Research suggests that about 40% of our daily actions are habits rather than conscious decisions. Understanding how habits form and how to change them can be transformative for personal development.
                
                The Habit Loop consists of three components:
                
                1. Cue: A trigger that tells your brain to go into automatic mode and which habit to use. Cues can be environmental (seeing your running shoes), temporal (a specific time of day), emotional (feeling stressed), or social (being around certain people).
                
                2. Routine: The behavior itself - the physical, mental, or emotional pattern that follows the cue. This is what we typically think of as the "habit."
                
                3. Reward: The benefit you gain from doing the behavior. This helps your brain figure out if this particular loop is worth remembering for the future.
                
                The key to changing habits lies in keeping the same cue and reward while changing the routine. For example, if you have a habit of eating a cookie when you feel stressed (cue: stress, routine: eating cookie, reward: feeling better), you might replace the cookie with a short walk or deep breathing exercises.
                
                Successful habit change also requires understanding the underlying craving that drives the habit loop. Often, we're not craving the behavior itself, but the neurochemical reward it provides - whether that's a sense of accomplishment, social connection, or stress relief.
                
                Research shows that it takes an average of 66 days for a new behavior to become automatic, though this can vary significantly depending on the complexity of the habit and individual differences.
                """,
                category: .psychology,
                readingTime: 5,
                tags: ["habits", "behavior", "psychology", "change"],
                difficulty: .intermediate,
                healthRelated: true
            )
        ]
        
        articles = healthArticles + scienceArticles + technologyArticles + psychologyArticles
        featuredArticles = Array(articles.prefix(3))
        
        // Sample quiz questions
        quizQuestions = [
            QuizQuestion(
                question: "What does HRV stand for?",
                options: ["Heart Rate Velocity", "Heart Rate Variability", "Heart Rhythm Variation", "Heart Rate Volume"],
                correctAnswerIndex: 1,
                explanation: "HRV stands for Heart Rate Variability, which measures the variation in time between heartbeats.",
                articleId: articles[0].id
            ),
            QuizQuestion(
                question: "Which sleep stage is most important for physical recovery?",
                options: ["Stage 1", "Stage 2", "Stage 3 (Deep Sleep)", "REM Sleep"],
                correctAnswerIndex: 2,
                explanation: "Stage 3, also known as deep sleep, is when the body repairs tissues, builds muscle, and strengthens the immune system.",
                articleId: articles[1].id
            )
        ]
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(articles) {
            userDefaults.set(encoded, forKey: articlesKey)
        }
        if let encoded = try? JSONEncoder().encode(quizQuestions) {
            userDefaults.set(encoded, forKey: questionsKey)
        }
    }
    
    private func loadSavedData() {
        if let data = userDefaults.data(forKey: articlesKey),
           let savedArticles = try? JSONDecoder().decode([Article].self, from: data) {
            // Merge saved bookmarks with sample data
            for savedArticle in savedArticles {
                if let index = articles.firstIndex(where: { $0.title == savedArticle.title }) {
                    articles[index] = savedArticle
                }
            }
        }
    }
}
