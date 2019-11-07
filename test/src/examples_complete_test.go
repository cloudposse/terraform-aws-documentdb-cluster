package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	// We need to create the ALB first because terraform does not wwait for it to be in the ready state before creating ECS target group
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer func() {
		if r := recover(); r != nil {
			terraform.Destroy(t, terraformOptions)
			assert.Fail(t, fmt.Sprintf("Panicked: %v", r))
		} else {
			terraform.Destroy(t, terraformOptions)
		}
	}()

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
	assert.Equal(t, "eg-test-documentdb-cluster", securityGroupName)

	// Run `terraform output` to get the value of an output variable
	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-test-documentdb-cluster", clusterName)

	// Run `terraform output` to get the value of an output variable
	endpoint := terraform.Output(t, terraformOptions, "endpoint")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, endpoint, "eg-test-documentdb-cluster.cluster")

	// Run `terraform output` to get the value of an output variable
	readerEndpoint := terraform.Output(t, terraformOptions, "reader_endpoint")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, readerEndpoint, "eg-test-documentdb-cluster.cluster-ro")
}
