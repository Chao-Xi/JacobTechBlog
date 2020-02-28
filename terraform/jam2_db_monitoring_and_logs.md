# AWS DB Monitoring, logs output and Alerts

## `main/var.tf`

```
variable "rds_cpu_threshold" {
  type = number
}

variable "rds_memory_threshold" {
  type    = number
  default = 512000000 # 512MB
}

variable "rds_storage_threshold" {
  type    = number
  default = 1024000000 # 10GB
}

variable "rds_connection_threshold" {
  type    = number
  default = 1000 # current max_connections is 624 need to be changed to 1024 lately
}

variable "rds_dbloadcpu_threshold" {
  type    = number
  default = 3 # current vCPU is 2, set 3 as alert threshold
}
```


## `modules/database/main.tf`

### `aws_db_parameter_group`

* `slow_query_log`: 1
* `long_query_time`: 10
* `general_log`: 1
* `log_output`: **file**

### `aws_db_instance`

*  `parameter_group_name  = "${aws_db_parameter_group.db_parameter_group.name}"`
*  `performance_insights_enabled    = true`
*  ` enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]`

### `aws_cloudwatch_log_group`

* `db_error_log_group`
* `db_general_log_group`
* `db_slowquery_log_group`

### `aws_sns_topic`

* `rds_alarms`

### `aws_cloudwatch_metric_alarm`

* `rds_cpu_utilization_too_high`
* `rds_freeable_memory_too_low`
* `rds_db_load_cpu_too_high`
* `rds_connections_too_high`
* `rds_freeable_storage_too_low`

```
resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "${var.JAM_INSTANCE}-mysql57-pg"
  family      = "mysql5.7"
  description = "Update default parameter group and enable error, general, slow query log output as FILE"
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "long_query_time"
    value = "10"
  }
  parameter {
    name  = "general_log"
    value = "1"
  }
  parameter {
    name  = "log_output"
    value = "file"
  }

}

resource "aws_db_instance" "db" {
  name                            = "${var.JAM_INSTANCE}"
  identifier                      = "${var.JAM_INSTANCE}-db"
  allocated_storage               = 100
  instance_class                  = "db.m5.large"
  engine                          = "mysql"
  availability_zone               = var.availability_zones.names[0]
  username                        = "jam"
  password                        = "${var.ADMIN_PASSWORD}"
  multi_az                        = false
  engine_version                  = "5.7.26"
  publicly_accessible             = false
  parameter_group_name            = "${aws_db_parameter_group.db_parameter_group.name}"
  db_subnet_group_name            = "${aws_db_subnet_group.db_subnet_group.name}"
  vpc_security_group_ids          = ["${aws_security_group.security-group.id}"]
  final_snapshot_identifier       = "${var.JAM_INSTANCE}-snapshot-finalizer"
  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
}

resource "aws_cloudwatch_log_group" "db_error_log_group" {
  name              = "/aws/rds/instance/${var.JAM_INSTANCE}-db/error"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "db_general_log_group" {
  name              = "/aws/rds/instance/${var.JAM_INSTANCE}-db/general"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "db_slowquery_log_group" {
  name              = "/aws/rds/instance/${var.JAM_INSTANCE}-db/slowquery"
  retention_in_days = 60
}

resource "aws_sns_topic" "rds_alarms" {
  name = "${var.JAM_INSTANCE}-db-alarms"
  tags = {
    "Reosurce"   = "RDS"
    "db-name"    = aws_db_instance.db.identifier
    "department" = "Jam"
    "team"       = "Devops"
    "create-by"  = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization_too_high" {
  alarm_name          = "${var.JAM_INSTANCE}-db-High-CPU-Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${var.rds_cpu_threshold}"
  alarm_description   = "Average database CPU utilization over last 10 minutes too high"
  alarm_actions       = ["${aws_sns_topic.rds_alarms.arn}"]
  ok_actions          = ["${aws_sns_topic.rds_alarms.arn}"]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }
}


resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory_too_low" {
  alarm_name          = "${var.JAM_INSTANCE}-db-Low-Freeable-Memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${var.rds_memory_threshold}"
  alarm_description   = "Average database freeable memory over last 10 minutes too low, performance may suffer"
  alarm_actions       = ["${aws_sns_topic.rds_alarms.arn}"]
  ok_actions          = ["${aws_sns_topic.rds_alarms.arn}"]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_freeable_storage_too_low" {
  alarm_name          = "${var.JAM_INSTANCE}-db-Low-Free-Storage-Space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${var.rds_storage_threshold}"
  alarm_description   = "Average database freeable storage space over last 10 minutes too low"
  alarm_actions       = ["${aws_sns_topic.rds_alarms.arn}"]
  ok_actions          = ["${aws_sns_topic.rds_alarms.arn}"]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_too_high" {
  alarm_name          = "${var.JAM_INSTANCE}-db-High-DB-Connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "${var.rds_connection_threshold}"
  alarm_description   = "Average database count of connections over last 10 minutes too high"
  alarm_actions       = ["${aws_sns_topic.rds_alarms.arn}"]
  ok_actions          = ["${aws_sns_topic.rds_alarms.arn}"]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }
}


resource "aws_cloudwatch_metric_alarm" "rds_db_load_cpu_too_high" {
  alarm_name          = "${var.JAM_INSTANCE}-db-High-Load-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DBLoadCPU"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "${var.rds_dbloadcpu_threshold}"
  alarm_description   = "Average database DBLoadCPU over last 5 minutes too high"
  alarm_actions       = ["${aws_sns_topic.rds_alarms.arn}"]
  # ok_actions          = ["${aws_sns_topic.rds_alarms.arn}"]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.db.identifier
  }
}
```

### `var.tf`

```
...
variable "rds_cpu_threshold" {
  type = number
}

variable "rds_memory_threshold" {
  type = number
}

variable "rds_storage_threshold" {
  type = number
}

variable "rds_connection_threshold" {
  type = number
}

variable "rds_dbloadcpu_threshold" {
  type = number
}
```

### `output.tf`

```
output "db_alarm_sns_topic_arn" {
  value = aws_sns_topic.rds_alarms.arn
}
```

