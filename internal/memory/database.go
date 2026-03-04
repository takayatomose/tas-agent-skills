package memory

import (
	"context"
	"database/sql"
	"encoding/json"
	"os"
	"path/filepath"

	_ "modernc.org/sqlite"
)

type sqliteMemory struct {
	db *sql.DB
}

func NewSqliteMemory(dbPath string) (MemoryService, error) {
	if err := os.MkdirAll(filepath.Dir(dbPath), 0755); err != nil {
		return nil, err
	}

	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return nil, err
	}

	s := &sqliteMemory{db: db}
	if err := s.init(); err != nil {
		db.Close()
		return nil, err
	}

	return s, nil
}

func (s *sqliteMemory) init() error {
	query := `
	CREATE TABLE IF NOT EXISTS knowledge (
		id TEXT PRIMARY KEY,
		title TEXT NOT NULL,
		content TEXT NOT NULL,
		tags TEXT,
		scope TEXT,
		normalized_title TEXT,
		content_hash TEXT,
		vector BLOB,
		created_at DATETIME,
		updated_at DATETIME
	);
	CREATE INDEX IF NOT EXISTS idx_knowledge_scope ON knowledge(scope);
	CREATE INDEX IF NOT EXISTS idx_knowledge_hash ON knowledge(content_hash);
	`
	_, err := s.db.Exec(query)
	return err
}

func (s *sqliteMemory) Store(ctx context.Context, k *Knowledge) error {
	tagsJSON, _ := json.Marshal(k.Tags)
	vectorJSON, _ := json.Marshal(k.Vector)

	query := `
	INSERT INTO knowledge (id, title, content, tags, scope, normalized_title, content_hash, vector, created_at, updated_at)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`
	_, err := s.db.ExecContext(ctx, query,
		k.ID, k.Title, k.Content, string(tagsJSON), k.Scope,
		k.NormalizedTitle, k.ContentHash, vectorJSON, k.CreatedAt, k.UpdatedAt,
	)
	return err
}

func (s *sqliteMemory) List(ctx context.Context, limit int, offset int) ([]Knowledge, error) {
	query := `SELECT id, title, content, tags, scope, normalized_title, content_hash, created_at, updated_at FROM knowledge LIMIT ? OFFSET ?`
	rows, err := s.db.QueryContext(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []Knowledge
	for rows.Next() {
		var k Knowledge
		var tagsStr string
		if err := rows.Scan(&k.ID, &k.Title, &k.Content, &tagsStr, &k.Scope, &k.NormalizedTitle, &k.ContentHash, &k.CreatedAt, &k.UpdatedAt); err != nil {
			return nil, err
		}
		json.Unmarshal([]byte(tagsStr), &k.Tags)
		results = append(results, k)
	}
	return results, nil
}

func (s *sqliteMemory) Delete(ctx context.Context, id string) error {
	_, err := s.db.ExecContext(ctx, "DELETE FROM knowledge WHERE id = ?", id)
	return err
}

func (s *sqliteMemory) Close() error {
	return s.db.Close()
}

// Search implements brute-force cosine similarity search
func (s *sqliteMemory) Search(ctx context.Context, queryVector []float32, scope string, tags []string, limit int) ([]SearchResult, error) {
	sqlQuery := `SELECT id, title, content, tags, scope, normalized_title, content_hash, vector, created_at, updated_at FROM knowledge`
	var args []interface{}
	if scope != "" {
		sqlQuery += " WHERE scope = ?"
		args = append(args, scope)
	}

	rows, err := s.db.QueryContext(ctx, sqlQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []Knowledge
	for rows.Next() {
		var k Knowledge
		var tagsStr string
		var vectorBLOB []byte
		if err := rows.Scan(&k.ID, &k.Title, &k.Content, &tagsStr, &k.Scope, &k.NormalizedTitle, &k.ContentHash, &vectorBLOB, &k.CreatedAt, &k.UpdatedAt); err != nil {
			return nil, err
		}
		json.Unmarshal([]byte(tagsStr), &k.Tags)
		json.Unmarshal(vectorBLOB, &k.Vector)
		items = append(items, k)
	}

	return RankResults(queryVector, items, limit), nil
}
