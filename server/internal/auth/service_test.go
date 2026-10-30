package auth

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"
)

type testRepository struct {
	credentials map[string]Credential
	wechatIDs   map[string]string
	sessions    map[string]Session
	revoked     map[string]bool
}

func newTestRepository() *testRepository {
	return &testRepository{
		credentials: make(map[string]Credential),
		wechatIDs:   make(map[string]string),
		sessions:    make(map[string]Session),
		revoked:     make(map[string]bool),
	}
}

func accountKey(account string, email bool) string {
	if email {
		return "email:" + account
	}
	return "username:" + account
}

func (r *testRepository) FindByAccount(_ context.Context, account string, email bool) (Credential, error) {
	credential, ok := r.credentials[accountKey(account, email)]
	if !ok {
		return Credential{}, ErrCredentialNotFound
	}
	return credential, nil
}

func (r *testRepository) FindByUserID(_ context.Context, userID string) (Credential, error) {
	for _, credential := range r.credentials {
		if credential.UserID == userID {
			return credential, nil
		}
	}
	return Credential{}, ErrCredentialNotFound
}

func (r *testRepository) FindByWeChatOpenID(_ context.Context, openID string) (Credential, error) {
	userID, ok := r.wechatIDs[openID]
	if !ok {
		return Credential{}, ErrCredentialNotFound
	}
	return r.FindByUserID(context.Background(), userID)
}

func (r *testRepository) CreateAccount(_ context.Context, account NewAccount) error {
	key := accountKey(account.Account, account.Email)
	if _, ok := r.credentials[key]; ok {
		return ErrAccountExists
	}
	r.credentials[key] = Credential{
		UserID: account.UserID, Nickname: account.Nickname,
		PasswordHash: account.PasswordHash, CreatedAt: time.Now().UTC(),
	}
	return nil
}

func (r *testRepository) CreateWeChatAccount(_ context.Context, account NewWeChatAccount) error {
	if _, ok := r.wechatIDs[account.OpenID]; ok {
		return ErrAccountExists
	}
	r.wechatIDs[account.OpenID] = account.UserID
	r.credentials["wechat:"+account.OpenID] = Credential{
		UserID: account.UserID, Nickname: account.Nickname, PasswordHash: account.PasswordHash,
		CreatedAt: time.Now().UTC(), WeChatAccount: true,
	}
	return nil
}

func (r *testRepository) UpdatePasswordAndRevokeSessions(_ context.Context, userID string, passwordHash []byte, _ time.Time) error {
	for key, credential := range r.credentials {
		if credential.UserID == userID {
			credential.PasswordHash = passwordHash
			r.credentials[key] = credential
		}
	}
	for id, session := range r.sessions {
		if session.UserID == userID {
			r.revoked[id] = true
		}
	}
	return nil
}

func (r *testRepository) CreateSession(_ context.Context, session Session) error {
	r.sessions[idFromHash(session.RefreshTokenHash)] = session
	return nil
}

func (r *testRepository) RotateSession(_ context.Context, oldHash [32]byte, replacement Session, now time.Time) (Session, error) {
	key := idFromHash(oldHash)
	session, ok := r.sessions[key]
	if !ok || r.revoked[key] || !session.ExpiresAt.After(now) {
		return Session{}, ErrInvalidSession
	}
	delete(r.sessions, key)
	session.RefreshTokenHash = replacement.RefreshTokenHash
	session.AccessTokenHash = replacement.AccessTokenHash
	session.ExpiresAt = replacement.ExpiresAt
	session.AccessTokenExpiresAt = replacement.AccessTokenExpiresAt
	r.sessions[idFromHash(session.RefreshTokenHash)] = session
	return session, nil
}

func (r *testRepository) RevokeSession(_ context.Context, refreshHash [32]byte, _ time.Time) error {
	key := idFromHash(refreshHash)
	if _, ok := r.sessions[key]; ok {
		r.revoked[key] = true
	}
	return nil
}

func (r *testRepository) AuthenticateAccess(_ context.Context, accessHash [32]byte, now time.Time) (string, error) {
	for id, session := range r.sessions {
		if !r.revoked[id] && session.AccessTokenHash == accessHash &&
			session.AccessTokenExpiresAt.After(now) && session.ExpiresAt.After(now) {
			return session.UserID, nil
		}
	}
	return "", ErrUnauthenticated
}

func idFromHash(hash [32]byte) string {
	return string(hash[:])
}

func newTestService(t *testing.T, repository *testRepository) *Service {
	t.Helper()
	service, err := NewService(repository)
	if err != nil {
		t.Fatal(err)
	}
	return service
}

func TestRegisterLoginAndPasswordStorage(t *testing.T) {
	repository := newTestRepository()
	service := newTestService(t, repository)
	ctx := context.Background()

	registered, err := service.Register(ctx, "Alice", "correct horse battery 123", "Alice")
	if err != nil {
		t.Fatal(err)
	}

	if registered.Profile.UserID == "" || registered.Profile.Nickname != "Alice" {
		t.Fatalf("unexpected profile: %+v", registered.Profile)
	}
	credential := repository.credentials["username:alice"]
	if !strings.HasPrefix(string(credential.PasswordHash), "$argon2id$") ||
		strings.Contains(string(credential.PasswordHash), "correct horse battery") {
		t.Fatalf("password was not stored as an Argon2id hash: %q", credential.PasswordHash)
	}
	if _, err := service.AuthenticateAccess(ctx, registered.AccessToken); err != nil {
		t.Fatalf("new access token was rejected: %v", err)
	}
	if expires := registered.AccessTokenExpiresAt.Sub(time.Now()); expires < 6*24*time.Hour || expires > 7*24*time.Hour {
		t.Fatalf("access token lifetime = %s, want approximately seven days", expires)
	}

	loggedIn, err := service.Login(ctx, "ALICE", "correct horse battery 123", "phone")
	if err != nil {
		t.Fatal(err)
	}
	if loggedIn.Profile.UserID != registered.Profile.UserID {
		t.Fatalf("login returned user %q, want %q", loggedIn.Profile.UserID, registered.Profile.UserID)
	}
	if _, err := service.Login(ctx, "Alice", "incorrect password 123", ""); !errors.Is(err, ErrInvalidCredentials) {
		t.Fatalf("wrong password error = %v, want generic invalid credentials", err)
	}
	if _, err := service.Login(ctx, "unknown", "correct horse battery 123", ""); !errors.Is(err, ErrInvalidCredentials) {
		t.Fatalf("unknown account error = %v, want generic invalid credentials", err)
	}
	if _, err := service.AuthenticateAccess(ctx, "invalid"); !errors.Is(err, ErrUnauthenticated) {
		t.Fatalf("malformed access token error = %v, want unauthenticated", err)
	}
}

func TestLoginWithWeChatOpenIDCreatesAndReusesAccount(t *testing.T) {
	repository := newTestRepository()
	service := newTestService(t, repository)
	ctx := context.Background()

	first, err := service.LoginWithWeChatOpenID(ctx, "trusted-open-id")
	if err != nil {
		t.Fatal(err)
	}
	second, err := service.LoginWithWeChatOpenID(ctx, "trusted-open-id")
	if err != nil {
		t.Fatal(err)
	}
	if first.Profile.UserID == "" || first.Profile.UserID != second.Profile.UserID ||
		first.Profile.Nickname != second.Profile.Nickname {
		t.Fatalf("WeChat account was not reused: first=%+v second=%+v", first.Profile, second.Profile)
	}
	if first.AccessToken == second.AccessToken {
		t.Fatal("separate login sessions unexpectedly shared an access token")
	}
	credential, err := repository.FindByWeChatOpenID(ctx, "trusted-open-id")
	if err != nil || !credential.WeChatAccount ||
		!strings.HasPrefix(string(credential.PasswordHash), "$argon2id$") {
		t.Fatalf("WeChat account credential = %+v, %v", credential, err)
	}
	if isWeChat, err := service.IsWeChatUser(ctx, first.Profile.UserID); err != nil || !isWeChat {
		t.Fatalf("IsWeChatUser() = %v, %v", isWeChat, err)
	}
}

func TestLoginWithWeChatOpenIDRejectsInvalidIDs(t *testing.T) {
	service := newTestService(t, newTestRepository())
	for _, openID := range []string{"", strings.Repeat("x", 129), "id\nforged"} {
		if _, err := service.LoginWithWeChatOpenID(context.Background(), openID); !errors.Is(err, ErrInvalidInput) {
			t.Errorf("LoginWithWeChatOpenID(%q) error = %v, want invalid input", openID, err)
		}
	}
}

func TestLegacyPasswordLoginAndChange(t *testing.T) {
	const legacyPassword = "correct horse battery"
	repository := newTestRepository()
	legacyHash, err := hashPassword(legacyPassword)
	if err != nil {
		t.Fatal(err)
	}
	repository.credentials["username:alice"] = Credential{
		UserID: "legacy-user", Nickname: "Alice", PasswordHash: legacyHash,
		CreatedAt: time.Now().UTC(),
	}
	service := newTestService(t, repository)
	ctx := context.Background()

	if _, err := service.Login(ctx, "alice", legacyPassword, "phone"); err != nil {
		t.Fatalf("login with legacy password: %v", err)
	}
	if err := service.ChangePassword(ctx, "legacy-user", legacyPassword, "new password 123"); err != nil {
		t.Fatalf("change password using legacy password: %v", err)
	}
	if _, err := service.Login(ctx, "alice", "new password 123", ""); err != nil {
		t.Fatalf("login with replacement password: %v", err)
	}
}

func TestRefreshRotatesTokensAndLogoutRevokesSession(t *testing.T) {
	repository := newTestRepository()
	service := newTestService(t, repository)
	ctx := context.Background()
	first, err := service.Register(ctx, "alice@example.com", "correct horse battery 123", "Alice")
	if err != nil {
		t.Fatal(err)
	}

	refreshed, err := service.Refresh(ctx, first.RefreshToken)
	if err != nil {
		t.Fatal(err)
	}
	if refreshed.RefreshToken == first.RefreshToken || refreshed.AccessToken == first.AccessToken {
		t.Fatal("refresh did not rotate both tokens")
	}
	if _, err := service.Refresh(ctx, first.RefreshToken); !errors.Is(err, ErrUnauthenticated) {
		t.Fatalf("reused refresh token error = %v, want unauthenticated", err)
	}
	if _, err := service.AuthenticateAccess(ctx, first.AccessToken); !errors.Is(err, ErrUnauthenticated) {
		t.Fatalf("old access token error = %v, want unauthenticated", err)
	}
	if _, err := service.AuthenticateAccess(ctx, refreshed.AccessToken); err != nil {
		t.Fatalf("new access token was rejected: %v", err)
	}
	if err := service.Logout(ctx, refreshed.RefreshToken); err != nil {
		t.Fatal(err)
	}
	if _, err := service.AuthenticateAccess(ctx, refreshed.AccessToken); !errors.Is(err, ErrUnauthenticated) {
		t.Fatalf("logged-out access token error = %v, want unauthenticated", err)
	}
}

func TestChangePasswordRevokesAllSessions(t *testing.T) {
	repository := newTestRepository()
	service := newTestService(t, repository)
	ctx := context.Background()
	first, err := service.Register(ctx, "alice", "correct horse battery 123", "Alice")
	if err != nil {
		t.Fatal(err)
	}
	second, err := service.Login(ctx, "alice", "correct horse battery 123", "tablet")
	if err != nil {
		t.Fatal(err)
	}

	if err := service.ChangePassword(ctx, first.Profile.UserID, "wrong password 123", "new password 123"); !errors.Is(err, ErrInvalidCredentials) {
		t.Fatalf("wrong current password error = %v", err)
	}
	if err := service.ChangePassword(ctx, first.Profile.UserID, "correct horse battery 123", "new password 123"); err != nil {
		t.Fatal(err)
	}
	for _, token := range []string{first.AccessToken, second.AccessToken} {
		if _, err := service.AuthenticateAccess(ctx, token); !errors.Is(err, ErrUnauthenticated) {
			t.Fatalf("session remained active after password change: %v", err)
		}
	}
	if _, err := service.Login(ctx, "alice", "new password 123", ""); err != nil {
		t.Fatalf("new password was rejected: %v", err)
	}
}

func TestRegisterRejectsInvalidInputsAndDuplicateAccount(t *testing.T) {
	service := newTestService(t, newTestRepository())
	ctx := context.Background()
	for _, input := range []struct {
		account, password, nickname string
	}{
		{"ab", "correct horse battery 123", "Alice"},
		{"alice", "short", "Alice"},
		{"alice", "correct horse battery 123", " "},
		{"not an email@", "correct horse battery 123", "Alice"},
		{"alice", "letters only", "Alice"},
		{"alice", "12345678", "Alice"},
	} {
		if _, err := service.Register(ctx, input.account, input.password, input.nickname); !errors.Is(err, ErrInvalidInput) {
			t.Errorf("Register(%q, ...) error = %v, want invalid input", input.account, err)
		}
	}
	if _, err := service.Register(ctx, "alice", "correct horse battery 123", "Alice"); err != nil {
		t.Fatal(err)
	}
	if _, err := service.Register(ctx, "ALICE", "correct horse battery 123", "Alice"); !errors.Is(err, ErrAccountExists) {
		t.Fatalf("duplicate account error = %v, want account exists", err)
	}
}
