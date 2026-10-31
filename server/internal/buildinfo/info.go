package buildinfo

import (
	"encoding/base64"
	"fmt"
)

// These values are replaced by the packaging scripts using Go linker flags.
var (
	Commit           = "unknown"
	Version          = "development"
	ChangelistBase64 = ""
)

type Info struct {
	CommitID   string
	Version    string
	Changelist string
}

func Current() (Info, error) {
	changelist, err := base64.StdEncoding.DecodeString(ChangelistBase64)
	if err != nil {
		return Info{}, fmt.Errorf("decode packaged changelist: %w", err)
	}
	return Info{CommitID: Commit, Version: Version, Changelist: string(changelist)}, nil
}
