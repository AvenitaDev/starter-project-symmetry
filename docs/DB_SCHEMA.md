# Firestore Database Schema

## Collection: articles

Each document inside `articles` represents one article.

### ArticleSchema

```ts
type ArticleSchema = {
  id: string
  // Firestore document ID
  // Example: "a1b2c3d4-e5f6-7890-abcd-1234567890ef"

  title: string
  // Article title
  // Example: "Avances recientes en IA"

  description: string
  // Short preview description
  // Example: "Resumen breve del artículo sobre tecnología."

  content: string
  // Full article content
  // Example: "Este es el contenido completo del artículo."

  urlToImage: string
  // Must reference an image stored in Firebase Cloud Storage
  // Path: media/articles/{filename}
  // Example: "media/articles/a1b2c3d4-e5f6-7890-abcd-1234567890ef.jpg"

  author: string
  // Example: "Lucía Fernández"

  publishedAt: string | null
  // ISO 8601 timestamp when the article was published
  // Example: "2026-03-05T10:15:30Z"
}
```
