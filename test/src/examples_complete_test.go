package test

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/docdb"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
)

// Test the Terraform module in examples/complete using Terratest.
func testExamplesComplete(t *testing.T, terraformOptions *terraform.Options, randID string, _ string) {

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

	// Assert that AWS says the cluster is available
	awsSession := session.Must(session.NewSession())
	docdbSvc := docdb.New(awsSession)

	// Describe the cluster
	result, err := docdbSvc.DescribeDBClusters(&docdb.DescribeDBClustersInput{
		DBClusterIdentifier: aws.String(clusterName),
	})
	assert.NoError(t, err)
	assert.Equal(t, "available", *result.DBClusters[0].Status, "Cluster is not in an available state")
}
