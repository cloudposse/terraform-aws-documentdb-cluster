// This file is a work-in-progress proposed set of utility functions
// to be standardized across all Cloud Posse Terraform modules.
// Most, if not all, of these functions will be replaced by
// Terratest functions as they become available.
// This file should be considered a temporary solution as of June 2024 and should not be duplicated

package test

import (
	"context"
	"encoding/base64"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/runtime"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"os"
	"sigs.k8s.io/aws-iam-authenticator/pkg/token"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/eks"
)

// Test the Terraform module in examples/complete using Terratest.
func testRunner(t *testing.T, vars map[string]interface{}, testFunc func(t *testing.T, terraformOptions *terraform.Options, randID string, results string)) {
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	terraformOptions := &terraform.Options{
		VarFiles: varFiles,
		Vars:     vars,
	}

	explicitTestRunner(t, terraformOptions, testFunc, terraformFolderRelativeToRoot)
}

func explicitTestRunner(t *testing.T, terraformOptions *terraform.Options,
	testFunc func(t *testing.T, terraformOptions *terraform.Options, randID string, results string), terraformFolderRelativeToRoot string) {

	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	// If supplied vars is nil, create a new map with the attributes
	vars := terraformOptions.Vars
	if vars == nil {
		vars = map[string]interface{}{
			"attributes": attributes,
		}
	} else {
		// If supplied vars is not nil, add the attributes to the existing map
		existingAttributes, ok := vars["attributes"].([]string)
		if !ok || len(existingAttributes) == 0 {
			vars["attributes"] = attributes
		} else {
			// If the existing map already has attributes, append the new attributes
			vars["attributes"] = append(existingAttributes, attributes...)
		}
	}

	rootFolder := "../../"

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)
	t.Logf("test run in temporary folder: %s", tempTestFolder)

	terraformOptions.TerraformDir = tempTestFolder
	terraformOptions.Upgrade = true
	terraformOptions.Vars = vars

	// Keep the output quiet
	if !testing.Verbose() {
		terraformOptions.Logger = logger.Discard
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// If the Go runtime crashes, try to clean up any resources that were created
	defer runtime.HandleCrash(func(i interface{}) {
		cleanup(t, terraformOptions, tempTestFolder)
	})

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	results := terraform.InitAndApply(t, terraformOptions)

	testFunc(t, terraformOptions, randID, results)
}

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	t.Logf("Cleanup running Terraform destroy in folder %s\n", tempTestFolder)
	// If Destroy fails, it will log the error, so we do not need to log it again,
	// but we want to fail immediately rather than delete the temp folder, so we
	// have a chance to inspect the state, fix what went wrong, and destroy the resources.
	if _, err := terraform.DestroyE(t, terraformOptions); err != nil {
		require.FailNow(t, "Terraform destroy failed.\nNot deleting temp test folder (%s)", tempTestFolder)
	}
	err := os.RemoveAll(tempTestFolder)
	assert.NoError(t, err)
}

// EKS support
func newClientset(cluster *eks.Cluster) (*kubernetes.Clientset, error) {
	gen, err := token.NewGenerator(true, false)
	if err != nil {
		return nil, err
	}
	opts := &token.GetTokenOptions{
		ClusterID: aws.StringValue(cluster.Name),
	}
	tok, err := gen.GetWithOptions(opts)
	if err != nil {
		return nil, err
	}
	ca, err := base64.StdEncoding.DecodeString(aws.StringValue(cluster.CertificateAuthority.Data))
	if err != nil {
		return nil, err
	}
	clientset, err := kubernetes.NewForConfig(
		&rest.Config{
			Host:        aws.StringValue(cluster.Endpoint),
			BearerToken: tok.Token,
			TLSClientConfig: rest.TLSClientConfig{
				CAData: ca,
			},
		},
	)
	if err != nil {
		return nil, err
	}
	return clientset, nil
}

// Check that at least one Node has the given label
func checkSomeNodeHasLabel(clientset *kubernetes.Clientset, labelKey string, labelValue string) bool {
	nodes, err := clientset.CoreV1().Nodes().List(context.Background(), metav1.ListOptions{})
	if err != nil {
		panic(err.Error())
	}
	for _, node := range nodes.Items {
		if value, ok := node.Labels[labelKey]; ok && value == labelValue {
			return true
		}
	}
	return false
}

// Check that at least one Node has the given taint
func checkSomeNodeHasTaint(clientset *kubernetes.Clientset, taintKey string, taintValue string, taintEffect corev1.TaintEffect) bool {
	nodes, err := clientset.CoreV1().Nodes().List(context.Background(), metav1.ListOptions{})
	if err != nil {
		panic(err.Error())
	}
	for _, node := range nodes.Items {
		for _, taint := range node.Spec.Taints {
			if taint.Key == taintKey && taint.Value == taintValue && taint.Effect == taintEffect {
				return true
			}
		}
	}
	return false
}
