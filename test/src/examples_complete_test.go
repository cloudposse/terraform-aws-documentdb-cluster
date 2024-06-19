package test

import (
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"k8s.io/apimachinery/pkg/util/runtime"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	// Test input variables
	vars := &map[string]interface{}{}

	// Terraform options and variables preparation
	randID := generateUniqueID()
	testFolder := createTestFolder(t)
	terraformOptions := buildTerraformOptions(randID, vars, testFolder)

	// Deferred cleanup steps

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, testFolder)

	// If Go runtime crashes, run `terraform destroy` to clean up any resources that were created
	defer runtime.HandleCrash(func(i interface{}) {
		terraform.Destroy(t, terraformOptions)
	})

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "172.16.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.0.0/19", "172.16.32.0/19"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.96.0/19", "172.16.128.0/19"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	securityGroupName := terraform.Output(t, terraformOptions, "security_group_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-test-documentdb-cluster-"+randID, securityGroupName)

	// Run `terraform output` to get the value of an output variable
	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-test-documentdb-cluster-"+randID, clusterName)

	// Run `terraform output` to get the value of an output variable
	endpoint := terraform.Output(t, terraformOptions, "endpoint")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, endpoint, "eg-test-documentdb-cluster-"+randID+".cluster")

	// Run `terraform output` to get the value of an output variable
	readerEndpoint := terraform.Output(t, terraformOptions, "reader_endpoint")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, readerEndpoint, "eg-test-documentdb-cluster-"+randID+".cluster-ro")
}

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()

	// Test input variables
	vars := &map[string]interface{}{
		"enabled": false,
	}

	// Terraform options and variables preparation
	randID := generateUniqueID()
	testFolder := createTestFolder(t)
	terraformOptions := buildTerraformOptions(randID, vars, testFolder)

	// Deferred cleanup steps

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, testFolder)

	// If Go runtime crashes, run `terraform destroy` to clean up any resources that were created
	defer runtime.HandleCrash(func(i interface{}) {
		terraform.Destroy(t, terraformOptions)
	})

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	results := terraform.InitAndApply(t, terraformOptions)

	// Output validation steps

	// Should complete successfully without creating or changing any resources.
	// Extract the "Resources:" section of the output to make the error message more readable.
	re := regexp.MustCompile(`Resources: [^.]+\.`)
	match := re.FindString(results)
	assert.Equal(t, "Resources: 0 added, 0 changed, 0 destroyed.", match, "Re-applying the same configuration should not change any resources")
}
