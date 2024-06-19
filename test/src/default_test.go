package test

import (
	"testing"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	testRunner(t, nil, testExamplesComplete)
}

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()

	vars := &map[string]interface{}{
		"enabled": false,
	}

	testRunner(t, vars, testExamplesCompleteDisabled)
}
