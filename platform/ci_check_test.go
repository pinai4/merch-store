package platform

import "testing"

// Temporary failing test to check that go-ci fails (#15). Not for merge.
func TestCICheckFails(t *testing.T) {
	t.Fatal("deliberate failure")
}
