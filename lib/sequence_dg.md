# Overall Sequence Diagram

This diagram shows a high-level “happy path” interaction through the app:  
user logs in, searches for a book, views details, adds it to a list, writes a review, and requests AI recommendations.

```mermaid
sequenceDiagram
    actor User
    participant UI          as Flutter UI
    participant AuthProv    as UserProvider/AuthService
    participant FirebaseAuth as Firebase Auth
    participant BookProv    as BookProvider
    participant GB          as GoogleBooksService
    participant GoogleBooks as Google Books API
    participant Firestore   as FirestoreService
    participant ReviewProv  as ReviewProvider
    participant OpenAIProv  as RecommendationProvider
    participant OpenAIAPI   as OpenAI API

    %% 1. Authentication
    User->>UI: Launch app
    UI->>AuthProv: checkCurrentUser()
    alt not authenticated
      UI-->>UI: show LoginScreen
      User->>UI: enter credentials + tap “Log In”
      UI->>AuthProv: login(email, password)
      AuthProv->>FirebaseAuth: signInWithEmailAndPassword
      FirebaseAuth-->>AuthProv: return User
      AuthProv-->>UI: login success
    end
    UI-->>UI: display HomeScreen

    %% 2. Search Flow
    User->>UI: type “harry potter” + tap Search
    UI->>BookProv: searchBooks("harry potter")
    BookProv->>GB: fetch volumes?q=harry+potter
    GB->>GoogleBooks: HTTP GET
    GoogleBooks-->>GB: JSON response
    GB-->>BookProv: parse List<Book>
    BookProv-->>UI: update searchResults

    %% 3. View Details & Reading List
    User->>UI: tap on a BookCard
    UI-->>UI: navigate to BookDetailScreen(book)
    BookDetailScreen->>Firestore: getUser(userId)
    Firestore-->>BookDetailScreen: return AppUser (reading lists)
    User->>BookDetailScreen: tap “Want to Read”
    BookDetailScreen->>Firestore: setUser(updatedAppUser)
    Firestore-->>BookDetailScreen: ack

    %% 4. Review Flow
    User->>BookDetailScreen: tap “Write a Review”
    UI-->>UI: navigate to ReviewScreen(book)
    User->>UI: enter review + rating + tap Submit
    UI->>ReviewProv: addReview(review)
    ReviewProv->>Firestore: add(reviewDoc)
    Firestore-->>ReviewProv: ack
    ReviewProv-->>UI: reviewsStream emits updated list

    %% 5. AI Recommendations
    User->>UI: tap “Refresh AI Suggestions”
    UI->>OpenAIProv: fetchRecommendations(genres, existingBookIds)
    OpenAIProv->>OpenAIAPI: chat.create(models:"gpt-3.5-turbo", prompt)
    OpenAIAPI-->>OpenAIProv: JSON array of "Title by Author"
    OpenAIProv-->>UI: update recommendations list
