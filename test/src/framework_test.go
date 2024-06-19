package test

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"k8s.io/apimachinery/pkg/util/runtime"
)

// Test the Terraform module in examples/complete using Terratest.
func testRunner(t *testing.T, vars *map[string]interface{}, testFunc func(t *testing.T, terraformOptions *terraform.Options, randID string, results string)) {
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	if vars == nil {
		vars = &map[string]interface{}{
			"attributes": attributes,
		}
	} else {
		(*vars)["attributes"] = attributes
	}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars:     *vars,
	}

	// Keep the output quiet
	if !testing.Verbose() {
		terraformOptions.Logger = logger.Discard
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// If Go runtime crashes, run `terraform destroy` to clean up any resources that were created
	defer runtime.HandleCrash(func(i interface{}) {
		terraform.Destroy(t, terraformOptions)
	})

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	results := terraform.InitAndApply(t, terraformOptions)

	testFunc(t, terraformOptions, randID, results)
}

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	err := os.RemoveAll(tempTestFolder)
	assert.NoError(t, err)
}
