resource "shoreline_notebook" "elasticsearch_disk_out_of_space_incident" {
  name       = "elasticsearch_disk_out_of_space_incident"
  data       = file("${path.module}/data/elasticsearch_disk_out_of_space_incident.json")
  depends_on = [shoreline_action.invoke_elasticsearch_disk_space_check,shoreline_action.invoke_elasticsearch_disk_check,shoreline_action.invoke_delete_old_data,shoreline_action.invoke_create_ebs_volume_and_attach]
}

resource "shoreline_file" "elasticsearch_disk_space_check" {
  name             = "elasticsearch_disk_space_check"
  input_file       = "${path.module}/data/elasticsearch_disk_space_check.sh"
  md5              = filemd5("${path.module}/data/elasticsearch_disk_space_check.sh")
  description      = "The Elasticsearch retention policy is not configured correctly, leading to excessive data storage."
  destination_path = "/agent/scripts/elasticsearch_disk_space_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "elasticsearch_disk_check" {
  name             = "elasticsearch_disk_check"
  input_file       = "${path.module}/data/elasticsearch_disk_check.sh"
  md5              = filemd5("${path.module}/data/elasticsearch_disk_check.sh")
  description      = "The Elasticsearch backups have not been performed as scheduled, leading to insufficient disk space."
  destination_path = "/agent/scripts/elasticsearch_disk_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "delete_old_data" {
  name             = "delete_old_data"
  input_file       = "${path.module}/data/delete_old_data.sh"
  md5              = filemd5("${path.module}/data/delete_old_data.sh")
  description      = "Implement a mechanism to automatically delete old Elasticsearch data that is no longer required."
  destination_path = "/agent/scripts/delete_old_data.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "create_ebs_volume_and_attach" {
  name             = "create_ebs_volume_and_attach"
  input_file       = "${path.module}/data/create_ebs_volume_and_attach.sh"
  md5              = filemd5("${path.module}/data/create_ebs_volume_and_attach.sh")
  description      = "Add more disk space to the Elasticsearch server to prevent future incidents of disk out of space."
  destination_path = "/agent/scripts/create_ebs_volume_and_attach.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_elasticsearch_disk_space_check" {
  name        = "invoke_elasticsearch_disk_space_check"
  description = "The Elasticsearch retention policy is not configured correctly, leading to excessive data storage."
  command     = "`chmod +x /agent/scripts/elasticsearch_disk_space_check.sh && /agent/scripts/elasticsearch_disk_space_check.sh`"
  params      = ["ELASTICSEARCH_DOMAIN_NAME","INDEX_NAME"]
  file_deps   = ["elasticsearch_disk_space_check"]
  enabled     = true
  depends_on  = [shoreline_file.elasticsearch_disk_space_check]
}

resource "shoreline_action" "invoke_elasticsearch_disk_check" {
  name        = "invoke_elasticsearch_disk_check"
  description = "The Elasticsearch backups have not been performed as scheduled, leading to insufficient disk space."
  command     = "`chmod +x /agent/scripts/elasticsearch_disk_check.sh && /agent/scripts/elasticsearch_disk_check.sh`"
  params      = ["AWS_REGION","ELASTICSEARCH_DOMAIN_NAME","S3_BUCKET_NAME"]
  file_deps   = ["elasticsearch_disk_check"]
  enabled     = true
  depends_on  = [shoreline_file.elasticsearch_disk_check]
}

resource "shoreline_action" "invoke_delete_old_data" {
  name        = "invoke_delete_old_data"
  description = "Implement a mechanism to automatically delete old Elasticsearch data that is no longer required."
  command     = "`chmod +x /agent/scripts/delete_old_data.sh && /agent/scripts/delete_old_data.sh`"
  params      = ["INDEX_NAME"]
  file_deps   = ["delete_old_data"]
  enabled     = true
  depends_on  = [shoreline_file.delete_old_data]
}

resource "shoreline_action" "invoke_create_ebs_volume_and_attach" {
  name        = "invoke_create_ebs_volume_and_attach"
  description = "Add more disk space to the Elasticsearch server to prevent future incidents of disk out of space."
  command     = "`chmod +x /agent/scripts/create_ebs_volume_and_attach.sh && /agent/scripts/create_ebs_volume_and_attach.sh`"
  params      = []
  file_deps   = ["create_ebs_volume_and_attach"]
  enabled     = true
  depends_on  = [shoreline_file.create_ebs_volume_and_attach]
}

