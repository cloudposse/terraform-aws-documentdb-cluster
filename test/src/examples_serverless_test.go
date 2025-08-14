package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/docdb"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/serverless using Terratest.
func testExamplesServerless(t *testing.T, terraformOptions *terraform.Options, randID string, _ string) {

	// Run `terraform output` to get the value of an output variable
	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-test-documentdb-cluster-"+randID, clusterName)

	// Assert that AWS says the cluster is available
	docdbSvc := docdb.NewFromConfig(AWSConfig())

	// Describe the cluster
	result, err := docdbSvc.DescribeDBClusters(context.TODO(), &docdb.DescribeDBClustersInput{
		DBClusterIdentifier: &clusterName,
	})
	assert.NoError(t, err)

	// Check if the slice is not empty and the status is available
	if len(result.DBClusters) > 0 {
		assert.Equal(t, "available", aws.ToString(result.DBClusters[0].Status), "Cluster is not in an available state")
	} else {
		assert.Fail(t, "No clusters found or cluster data is incomplete")
	}

	if result.DBClusters[0].ServerlessV2ScalingConfiguration != nil {
		assert.Equal(t, float64(0.5), aws.ToFloat64(result.DBClusters[0].ServerlessV2ScalingConfiguration.MinCapacity), "Min capacity is not as expected")
		assert.Equal(t, float64(2), aws.ToFloat64(result.DBClusters[0].ServerlessV2ScalingConfiguration.MaxCapacity), "Max capacity is not as expected")
	} else {
		assert.Fail(t, "Serverless V2 scaling configuration is not set")
	}
}
