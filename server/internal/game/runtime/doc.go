// Package runtime provides an in-memory, server-authoritative game domain.
//
// NewSession deals a complete, validated two-pack deck clockwise (25 cards per
// player, eight bottom cards). Config supplies the initial dealer; a declaration
// chooses trump, not a different dealer. The declaration phase is the logical
// declaration window following the atomic deal: any seat may declare until four
// clockwise passes close it. Declaration/counter cards remain in the player's
// hand; their identities are stored privately as proofs rather than discarded.
//
// Apply implements declaration, initial bury, counter polling and replacement
// bury, look-back, play, settlement and four-player continuation. The pure state
// transition checks expected versions and clones inputs. Repository additionally
// authenticates seat ownership, serializes transitions and deduplicates request
// IDs. Retries must include the same complete action, including expected version.
// Player identifiers must be authenticated by a future transport before Submit.
//
// State can be JSON-serialized for trusted server use, but contains every hidden
// card. View and Repository.Snapshot are the only client-facing projections.
// AvailableAction lists private opportunities, not a strategy or exhaustive
// enumeration of playable combinations. A zero play Count means the leader may
// select any nonempty legal combination; all selections still go through Apply.
//
// Teams are seats 0/2 and 1/3. Shuffle is injected for reproducibility; the default
// uses crypto/rand. Repository has no durable storage integration for either
// normal or practice sessions. A fresh repository is empty, and Delete removes
// both state and retry receipts.
//
// Trick scoring and settlement use engine helpers, with effective-trump suit
// validation and mandatory-level barriers enforced here. The business rules do
// not assign a bottom multiplier to 510k: runtime uses the single-card multiplier
// for that component, then applies its separate sky-earth override. For compound
// throws, the largest constituent pair/tractor determines the bottom multiplier.
package runtime
