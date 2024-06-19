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
)

// buildTerraformOptions builds the struct terraform.Options required to run Terraform commands
func buildTerraformOptions(randID string, vars *map[string]interface{}, tempTestFolder string) *terraform.Options {
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	attributes := []string{randID}

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

	return terraformOptions
}

// cleanup deletes the test folder and destroys the resources created by the test
func cleanup(t *testing.T, terraformOptions *terraform.Options, testFolder string) {
	terraform.Destroy(t, terraformOptions)
	
	err := os.RemoveAll(testFolder)
	assert.NoError(t, err)
}

// generateUniqueID generates a unique ID that is used to identify resources
func generateUniqueID() string {
	return strings.ToLower(random.UniqueId())
}

// createTestFolder creates a folder to store the Terraform code used in the test
func createTestFolder(t *testing.T) string {
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"

	return testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)
}
