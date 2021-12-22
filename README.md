# Usage
<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |

## Providers

| Name | Version |
|------|---------|
| archive | n/a |
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_tag\_value | Tag value to identify which AMIs (latest) will be updated in the launch template. | `any` | n/a | yes |
| name | App name | `any` | n/a | yes |
| schedule\_expression | CRON expression to invoke the lambda | `any` | n/a | yes |

## Outputs

No output.

<!--- END_TF_DOCS --->
