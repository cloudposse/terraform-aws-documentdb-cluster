package test

import (
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"os"
	"regexp"
	"strings"
	"testing"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	testRunner(t, nil, testExamplesComplete)
}

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()

	vars := map[string]interface{}{
		"enabled": false,
	}
	testRunner(t, vars, testExamplesCompleteDisabled)
}

func testExamplesCompleteDisabled(t *testing.T, terraformOptions *terraform.Options, randID string, results string) {
	// Should complete successfully without creating or changing any resources.
	// Extract the "Resources:" section of the output to make the error message more readable.
	re := regexp.MustCompile(`Resources: [^.]+\.`)
	match := re.FindString(results)
	assert.Equal(t, "Resources: 0 added, 0 changed, 0 destroyed.", match, "Re-applying the same configuration should not change any resources")
}

// To speed up debugging, allow running the tests on an existing deployment,
// without creating and destroying one.
// Run this manually by creating a deployment in examples/complete with:
//
//	  export EXISTING_DEPLOYMENT_ATTRIBUTE="<your-name>"
//   terraform init -upgrade
//	  terraform apply -var-file fixtures.us-east-2.tfvars -var "attributes=[\"$EXISTING_DEPLOYMENT_ATTRIBUTE\"]"
//
// then in this directory (test/src) run
//	  go test -run Test_ExistingDeployment

func Test_ExistingDeployment(t *testing.T) {
	randID := strings.ToLower(os.Getenv("EXISTING_DEPLOYMENT_ATTRIBUTE"))
	if randID == "" {
		t.Skip("(This is normal): EXISTING_DEPLOYMENT_ATTRIBUTE is not set, skipping...")
		return
	}

	attributes := []string{randID}

	varFiles := []string{"fixtures.us-east-2.tfvars"}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// Keep the output quiet
	if !testing.Verbose() {
		terraformOptions.Logger = logger.Discard
	}

	testExamplesComplete(t, terraformOptions, randID, "")
}
