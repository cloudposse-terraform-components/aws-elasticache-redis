package test

import (
	"fmt"
	"strings"
	"testing"

	helper "github.com/cloudposse/test-helpers/pkg/atmos/component-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/assert"
)

type ComponentSuite struct {
	helper.TestSuite
}

func (s *ComponentSuite) TestBasic() {
	const component = "elasticache-redis/basic"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	engineName := "redis"
	uniqueSuffix := strings.ToLower(random.UniqueId())

	inputs := map[string]any{
		"name": fmt.Sprintf("%s-%s", engineName, uniqueSuffix),
		"redis_clusters": map[string]any{
			"redis-test": map[string]any{
				"num_shards":         0,
				"replicas_per_shard": 1,
				"num_replicas":       1,
				"engine":             engineName,
				"engine_version":     "6.2",
				"instance_type":      "cache.t4g.small",
				"parameters": []map[string]any{
					{
						"name":  "extended-redis-compatibility",
						"value": "yes",
					},
				},
			},
		},
	}

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, &inputs)
	assert.NotNil(s.T(), options)

	s.DriftTest(component, stack, &inputs)
}

func (s *ComponentSuite) TestEnabledFlag() {
	const component = "elasticache-redis/disabled"
	const stack = "default-test"
	s.VerifyEnabledFlag(component, stack, nil)
}

func TestRunSuite(t *testing.T) {
	suite := new(ComponentSuite)

	suite.AddDependency(t, "vpc", "default-test", nil)

	subdomain := strings.ToLower(random.UniqueId())
	inputs := map[string]any{
		"zone_config": []map[string]any{
			{
				"subdomain": subdomain,
				"zone_name": "components.cptest.test-automation.app",
			},
		},
	}

	suite.AddDependency(t, "dns-delegated", "default-test", &inputs)

	helper.Run(t, suite)
}
