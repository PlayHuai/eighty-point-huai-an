package buildinfo

import (
	"encoding/base64"
	"testing"
)

func TestCurrentReturnsPackagedValues(t *testing.T) {
	oldCommit, oldVersion, oldChangelist := Commit, Version, ChangelistBase64
	t.Cleanup(func() { Commit, Version, ChangelistBase64 = oldCommit, oldVersion, oldChangelist })
	Commit, Version = "abc123", "1.2.3"
	ChangelistBase64 = base64.StdEncoding.EncodeToString([]byte("# 更新记录\n- \"Bug\" 修复\n- 建议"))
	info, err := Current()
	if err != nil || info.CommitID != Commit || info.Version != Version || info.Changelist != "# 更新记录\n- \"Bug\" 修复\n- 建议" {
		t.Fatalf("unexpected packaged info: %+v, %v", info, err)
	}
	ChangelistBase64 = "invalid!"
	if _, err := Current(); err == nil {
		t.Fatal("invalid packaged metadata was silently accepted")
	}
}
