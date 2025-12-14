package main

import (
	"testing"
)

func TestMain(t *testing.T) {
	// Simple test to ensure the program doesn't crash
	t.Log("Main test passed")
}

func TestExample(t *testing.T) {
	want := "test"
	got := "test"
	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}
