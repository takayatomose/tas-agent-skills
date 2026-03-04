package memory

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"time"

	"github.com/google/uuid"
)

type Manager struct {
	service   MemoryService
	embedding EmbeddingProvider
}

func NewManager(service MemoryService, embedding EmbeddingProvider) *Manager {
	return &Manager{
		service:   service,
		embedding: embedding,
	}
}

func (m *Manager) Store(ctx context.Context, title, content, scope string, tags []string) (string, error) {
	// 1. Generate Embedding
	vector, err := m.embedding.GenerateEmbedding(ctx, content)
	if err != nil {
		return "", err
	}

	// 2. Prepare Knowledge Object
	id := uuid.New().String()
	now := time.Now()
	hash := sha256.Sum256([]byte(content))

	k := &Knowledge{
		ID:              id,
		Title:           title,
		Content:         content,
		Tags:            tags,
		Scope:           scope,
		NormalizedTitle: strings.ToLower(strings.TrimSpace(title)),
		ContentHash:     hex.EncodeToString(hash[:]),
		Vector:          vector,
		CreatedAt:       now,
		UpdatedAt:       now,
	}

	// 3. Store in DB
	if err := m.service.Store(ctx, k); err != nil {
		return "", err
	}

	return id, nil
}

func (m *Manager) Search(ctx context.Context, query string, scope string, tags []string, limit int) ([]SearchResult, error) {
	// 1. Generate Embedding for Query
	vector, err := m.embedding.GenerateEmbedding(ctx, query)
	if err != nil {
		return nil, err
	}

	// 2. Search in DB
	return m.service.Search(ctx, vector, scope, tags, limit)
}

func (m *Manager) List(ctx context.Context, limit, offset int) ([]Knowledge, error) {
	return m.service.List(ctx, limit, offset)
}

func (m *Manager) Delete(ctx context.Context, id string) error {
	return m.service.Delete(ctx, id)
}

func (m *Manager) Close() error {
	return m.service.Close()
}
