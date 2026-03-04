package memory

import (
	"context"
	"time"
)

// Knowledge represents a single piece of stored information
type Knowledge struct {
	ID              string   `json:"id"`
	Title           string   `json:"title"`
	Content         string   `json:"content"`
	Tags            []string `json:"tags"`
	Scope           string   `json:"scope"`
	ParentID        string
	ChunkIndex      int
	NormalizedTitle string    `json:"normalized_title"`
	ContentHash     string    `json:"content_hash"`
	Vector          []float32 `json:"vector,omitempty"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

// SearchResult represents a knowledge item with its similarity score
type SearchResult struct {
	Knowledge
	Score float32 `json:"score"`
}

// MemoryService defines the interface for memory operations
type MemoryService interface {
	Store(ctx context.Context, k *Knowledge) error
	Search(ctx context.Context, queryVector []float32, scope string, tags []string, limit int) ([]SearchResult, error)
	List(ctx context.Context, limit int, offset int) ([]Knowledge, error)
	Delete(ctx context.Context, id string) error
	Close() error
}
