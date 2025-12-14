package main

import "testing"

func TestMain(t *testing.T) {
	t.Log("Running basic test")
	// Basic test to ensure package compiles
	if 1+1 != 2 {
		t.Error("Math is broken")
	}
}
