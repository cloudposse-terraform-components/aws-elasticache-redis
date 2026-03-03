---
tags:
  - component/elasticache-redis
  - layer/data
  - provider/aws
---

# Component: `elasticache-redis`

This component provisions AWS [ElastiCache Redis](https://aws.amazon.com/elasticache/redis/) clusters.
The `engine` can either be `redis` or `valkey`. For more information, see
[why aws supports valkey](https://aws.amazon.com/blogs/opensource/why-aws-supports-valkey/).
## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

`stacks/catalog/elasticache/elasticache-redis/defaults.yaml` file (default settings for all Redis clusters):

```yaml
components:
  terraform:
    elasticache-redis:
      vars:
        enabled: true
        name: "elasticache-redis"
        family: redis7.x
        egress_cidr_blocks: ["0.0.0.0/0"]
        port: 6379
        at_rest_encryption_enabled: true
        transit_encryption_enabled: false
        apply_immediately: false
        automatic_failover_enabled: false
        cloudwatch_metric_alarms_enabled: false
        snapshot_retention_limit: 1
        snapshot_window: "06:00-07:00"
        maintenance_window: "tue:08:00-tue:09:00"
        # Global defaults for all redis_clusters (can be overridden per cluster)
        engine: "redis"
        instance_type: cache.t4g.small
        num_replicas: 1
        num_shards: 0
        replicas_per_shard: 0
        create_parameter_group: true
        parameters: []
        redis_clusters:
          redis-main:
            engine_version: "7.0"
            parameters:
              - name: notify-keyspace-events
                value: "lK"
```

`stacks/org/ou/account/region.yaml` file (imports defaults and overrides per-cluster settings):

```yaml
import:
  - catalog/elasticache/elasticache-redis/defaults.yaml

components:
  terraform:
    elasticache-redis:
      vars:
        enabled: true
        redis_clusters:
          redis-main:
            engine_version: "7.0"
            instance_type: cache.t4g.small
            # Per-cluster overrides of the global defaults
            num_replicas: 2       # override global default of 1
            num_shards: 3         # override global default of 0 (enables cluster mode)
            replicas_per_shard: 1 # override global default of 0
            parameters:
              - name: notify-keyspace-events
                value: lK
```

Alternatively, if any per-cluster defaults are not covered by component-level variables,
use [YAML anchors](https://yaml.org/spec/1.2.2/#3222-anchors-and-aliases) to define shared
values once and merge them into each cluster entry:

```yaml
# stacks/catalog/elasticache/elasticache-redis/defaults.yaml
anchors:
  default_redis: &default_redis
    engine: "redis"
    engine_version: "7.0"
    instance_type: cache.t4g.small
    num_replicas: 1
    num_shards: 0
    replicas_per_shard: 0

components:
  terraform:
    elasticache-redis:
      vars:
        enabled: true
        name: "elasticache-redis"
        family: redis7.x
        port: 6379
        at_rest_encryption_enabled: true
        transit_encryption_enabled: false
        apply_immediately: false
        automatic_failover_enabled: false
        cloudwatch_metric_alarms_enabled: false
        snapshot_retention_limit: 1
        redis_clusters:
          redis-main:
            <<: *default_redis     # merge anchor defaults
            num_replicas: 2        # override anchor value
          redis-valkey:
            <<: *default_redis
            engine: "valkey"       # override engine to valkey
            num_shards: 3          # enable cluster mode
            replicas_per_shard: 1
          redis-cache:
            <<: *default_redis     # all anchor defaults apply
```

<!-- prettier-ignore-start -->
<!-- prettier-ignore-end -->


<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.73.0, < 7.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns_delegated"></a> [dns\_delegated](#module\_dns\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_redis_clusters"></a> [redis\_clusters](#module\_redis\_clusters) | ./modules/redis_cluster | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |
| <a name="module_vpc_ingress"></a> [vpc\_ingress](#module\_vpc\_ingress) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_rules"></a> [additional\_security\_group\_rules](#input\_additional\_security\_group\_rules) | A list of Security Group rule objects to add to the created security group, in addition to the ones this module normally creates. | `list(any)` | `[]` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | Alarm action list | `list(string)` | `[]` | no |
| <a name="input_alarm_cpu_threshold_percent"></a> [alarm\_cpu\_threshold\_percent](#input\_alarm\_cpu\_threshold\_percent) | CPU threshold alarm level | `number` | `75` | no |
| <a name="input_alarm_memory_threshold_bytes"></a> [alarm\_memory\_threshold\_bytes](#input\_alarm\_memory\_threshold\_bytes) | Ram threshold alarm level | `number` | `10000000` | no |
| <a name="input_allow_all_egress"></a> [allow\_all\_egress](#input\_allow\_all\_egress) | If `true`, the created security group will allow egress on all ports and protocols to all IP address.<br/>If this is false and no egress rules are otherwise specified, then no egress will be allowed. | `bool` | `true` | no |
| <a name="input_allow_ingress_from_this_vpc"></a> [allow\_ingress\_from\_this\_vpc](#input\_allow\_ingress\_from\_this\_vpc) | If set to `true`, allow ingress from the VPC CIDR for this account | `bool` | `true` | no |
| <a name="input_allow_ingress_from_vpc_stages"></a> [allow\_ingress\_from\_vpc\_stages](#input\_allow\_ingress\_from\_vpc\_stages) | List of stages to pull VPC ingress cidr and add to security group | `list(string)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately | `bool` | n/a | yes |
| <a name="input_at_rest_encryption_enabled"></a> [at\_rest\_encryption\_enabled](#input\_at\_rest\_encryption\_enabled) | Enable encryption at rest | `bool` | n/a | yes |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_auth_token_enabled"></a> [auth\_token\_enabled](#input\_auth\_token\_enabled) | Enable auth token | `bool` | `true` | no |
| <a name="input_auth_token_update_strategy"></a> [auth\_token\_update\_strategy](#input\_auth\_token\_update\_strategy) | Strategy to use when updating the auth\_token. Valid values are `SET`, `ROTATE`, and `DELETE`. Defaults to `ROTATE`. | `string` | `"ROTATE"` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Specifies whether minor version engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window. Only supported if the engine version is 6 or higher. | `bool` | `false` | no |
| <a name="input_automatic_failover_enabled"></a> [automatic\_failover\_enabled](#input\_automatic\_failover\_enabled) | Enable automatic failover | `bool` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zone IDs | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_metric_alarms_enabled"></a> [cloudwatch\_metric\_alarms\_enabled](#input\_cloudwatch\_metric\_alarms\_enabled) | Boolean flag to enable/disable CloudWatch metrics alarms | `bool` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_create_parameter_group"></a> [create\_parameter\_group](#input\_create\_parameter\_group) | Default setting for whether a new parameter group should be created for all Redis clusters. Set to false to use an existing parameter group. Can be overridden per cluster in redis\_clusters. | `bool` | `true` | no |
| <a name="input_data_tiering_enabled"></a> [data\_tiering\_enabled](#input\_data\_tiering\_enabled) | Enables data tiering. Data tiering is only supported for replication groups using the r6gd node type. | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Default description for all Redis replication groups. Can be overridden per cluster in redis\_clusters. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>  format = string<br/>  labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_delegated_component_name"></a> [dns\_delegated\_component\_name](#input\_dns\_delegated\_component\_name) | The name of the Delegated DNS component | `string` | `"dns-delegated"` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | Egress CIDR blocks for the created security group. Only used when `allow_all_egress` is `false`. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_egress_cidr_blocks_rule_description"></a> [egress\_cidr\_blocks\_rule\_description](#input\_egress\_cidr\_blocks\_rule\_description) | Description for the security group rule allowing egress to the CIDR blocks in `egress_cidr_blocks`. Only used when `allow_all_egress` is `false`. | `string` | `"Selectively allow outbound traffic"` | no |
| <a name="input_eks_component_names"></a> [eks\_component\_names](#input\_eks\_component\_names) | The names of the eks components | `set(string)` | `[]` | no |
| <a name="input_eks_security_group_enabled"></a> [eks\_security\_group\_enabled](#input\_eks\_security\_group\_enabled) | Use the eks default security group | `bool` | `false` | no |
| <a name="input_elasticache_subnet_group_name"></a> [elasticache\_subnet\_group\_name](#input\_elasticache\_subnet\_group\_name) | Subnet group name for the ElastiCache instance | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Default cache engine for all Redis clusters. Valid values: `redis` or `valkey`. Can be overridden per cluster in redis\_clusters. | `string` | `"redis"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_family"></a> [family](#input\_family) | Redis family | `string` | n/a | yes |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Default name of the final snapshot to create before deleting all Redis clusters. If null, no final snapshot is created. Can be overridden per cluster in redis\_clusters. | `string` | `null` | no |
| <a name="input_global_replication_group_id"></a> [global\_replication\_group\_id](#input\_global\_replication\_group\_id) | The ID of the global replication group to which this replication group should belong. If this parameter is specified, the replication group is added to the specified global replication group as a secondary replication group; otherwise, the replication group is not part of any global replication group. If global\_replication\_group\_id is set, the num\_node\_groups parameter cannot be set. | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | CIDR blocks for permitted ingress | `list(string)` | `[]` | no |
| <a name="input_ingress_cidr_blocks_rule_description"></a> [ingress\_cidr\_blocks\_rule\_description](#input\_ingress\_cidr\_blocks\_rule\_description) | Description for the security group rule allowing ingress from the CIDR blocks in `ingress_cidr_blocks`. | `string` | `"Selectively allow inbound traffic"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Default instance type for all Redis clusters. Can be overridden per cluster in redis\_clusters. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ARN of the key that you wish to use if encrypting at rest. If not supplied, uses service managed encryption. `at_rest_encryption_enabled` must be set to `true` | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_log_delivery_configuration"></a> [log\_delivery\_configuration](#input\_log\_delivery\_configuration) | The log\_delivery\_configuration block allows the streaming of Redis SLOWLOG or Redis Engine Log to CloudWatch Logs or Kinesis Data Firehose. Max of 2 blocks. | `list(map(any))` | `[]` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance window. Format: ddd:hh:mm-ddd:hh:mm (UTC). Defaults to null (AWS chooses the window). | `string` | `null` | no |
| <a name="input_multi_az_enabled"></a> [multi\_az\_enabled](#input\_multi\_az\_enabled) | Multi AZ (Automatic Failover must also be enabled.  If Cluster Mode is enabled, Multi AZ is on by default, and this setting is ignored) | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | The network type of the cluster. Valid values: ipv4, ipv6, dual\_stack. | `string` | `"ipv4"` | no |
| <a name="input_notification_topic_arn"></a> [notification\_topic\_arn](#input\_notification\_topic\_arn) | Notification topic arn | `string` | `""` | no |
| <a name="input_num_replicas"></a> [num\_replicas](#input\_num\_replicas) | Default number of replicas in the replica set for all Redis clusters. Can be overridden per cluster in redis\_clusters. | `number` | `1` | no |
| <a name="input_num_shards"></a> [num\_shards](#input\_num\_shards) | Default number of shards (node groups) for Redis clusters. Value > 0 enables cluster mode. Can be overridden per cluster in redis\_clusters. | `number` | `0` | no |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Number (ARN) | `list(string)` | `[]` | no |
| <a name="input_parameter_group_description"></a> [parameter\_group\_description](#input\_parameter\_group\_description) | Managed by Terraform | `string` | `null` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Default override parameter group name for all Redis clusters. Can be overridden per cluster in redis\_clusters. | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Default list of Redis parameters to configure for all clusters. Can be overridden per cluster in redis\_clusters. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_port"></a> [port](#input\_port) | Port number | `number` | n/a | yes |
| <a name="input_redis_clusters"></a> [redis\_clusters](#input\_redis\_clusters) | Redis cluster configuration | `map(any)` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_replicas_per_shard"></a> [replicas\_per\_shard](#input\_replicas\_per\_shard) | Default number of replica nodes per shard for Redis clusters. Valid values are 0 to 5. Can be overridden per cluster in redis\_clusters. | `number` | `0` | no |
| <a name="input_replication_group_id"></a> [replication\_group\_id](#input\_replication\_group\_id) | Default replication group ID for all Redis clusters. Must be 1-20 alphanumeric characters or hyphens, start with a letter, and not end with or contain consecutive hyphens. Can be overridden per cluster in redis\_clusters. | `string` | `""` | no |
| <a name="input_serverless_cache_usage_limits"></a> [serverless\_cache\_usage\_limits](#input\_serverless\_cache\_usage\_limits) | The usage limits for the serverless cache. Expected keys are `data_storage` (with `maximum`, `minimum`, `unit`) and `ecpu_per_second` (with `maximum`, `minimum`). | `map(any)` | `{}` | no |
| <a name="input_serverless_enabled"></a> [serverless\_enabled](#input\_serverless\_enabled) | Flag to enable/disable creation of a serverless redis cluster | `bool` | `false` | no |
| <a name="input_serverless_major_engine_version"></a> [serverless\_major\_engine\_version](#input\_serverless\_major\_engine\_version) | The major version of the engine to use for the serverless cluster | `string` | `"7"` | no |
| <a name="input_serverless_snapshot_arns_to_restore"></a> [serverless\_snapshot\_arns\_to\_restore](#input\_serverless\_snapshot\_arns\_to\_restore) | The list of ARN(s) of the snapshot that the new serverless cache will be created from. Available for Redis only. | `list(string)` | `[]` | no |
| <a name="input_serverless_snapshot_time"></a> [serverless\_snapshot\_time](#input\_serverless\_snapshot\_time) | The daily time (in UTC, format HH:MM) that snapshots will be created from the serverless cache. | `string` | `"06:00"` | no |
| <a name="input_serverless_user_group_id"></a> [serverless\_user\_group\_id](#input\_serverless\_user\_group\_id) | User Group ID to associate with the serverless replication group | `string` | `null` | no |
| <a name="input_snapshot_arns"></a> [snapshot\_arns](#input\_snapshot\_arns) | Default list of ARNs of Redis RDB snapshot files in S3 to restore into all new clusters. Can be overridden per cluster in redis\_clusters. | `list(string)` | `[]` | no |
| <a name="input_snapshot_name"></a> [snapshot\_name](#input\_snapshot\_name) | Default name of a snapshot to restore into all new Redis clusters. Changing this forces a new resource. Can be overridden per cluster in redis\_clusters. | `string` | `null` | no |
| <a name="input_snapshot_retention_limit"></a> [snapshot\_retention\_limit](#input\_snapshot\_retention\_limit) | The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. | `number` | `0` | no |
| <a name="input_snapshot_window"></a> [snapshot\_window](#input\_snapshot\_window) | The daily time range (in UTC) during which ElastiCache begins taking a daily snapshot. Format: hh:mm-hh:mm. Defaults to null (AWS chooses the window). Has no effect when snapshot\_retention\_limit is 0. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_transit_encryption_enabled"></a> [transit\_encryption\_enabled](#input\_transit\_encryption\_enabled) | Enable TLS | `bool` | n/a | yes |
| <a name="input_transit_encryption_mode"></a> [transit\_encryption\_mode](#input\_transit\_encryption\_mode) | Transit encryption mode. Valid values are 'preferred' and 'required' | `string` | `null` | no |
| <a name="input_user_group_ids"></a> [user\_group\_ids](#input\_user\_group\_ids) | User Group ID to associate with the replication group | `list(string)` | `null` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | The name of a VPC component | `string` | `"vpc"` | no |
| <a name="input_vpc_ingress_component_name"></a> [vpc\_ingress\_component\_name](#input\_vpc\_ingress\_component\_name) | The name of a Ingress VPC component | `string` | `"vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redis_clusters"></a> [redis\_clusters](#output\_redis\_clusters) | Redis cluster objects |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The security group ID of the ElastiCache Redis cluster |
| <a name="output_transit_encryption_mode"></a> [transit\_encryption\_mode](#output\_transit\_encryption\_mode) | TLS in-transit encryption mode for Redis cluster |
<!-- markdownlint-restore -->



## References


- [cloudposse-terraform-components](https://github.com/orgs/cloudposse-terraform-components/repositories) - Cloud Posse's upstream component




[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-elasticache-redis&utm_content=)

