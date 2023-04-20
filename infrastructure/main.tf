provider "google" {
  project = "learn-kubernetes-380519"
  region  = "europe-central2"
  zone    = "europe-central2-a"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}

resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_pubsub_topic" "bucket_notification_topic" {
  name = "bucket-notification-topic"
}

resource "google_storage_bucket" "bucket_function_sources" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-source"
  location                    = "europe-central2"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "function_source_file" {
  bucket = google_storage_bucket.bucket_function_sources.name
  name   = "function-source.zip"
  source = "../function-source.zip"
}

resource "google_cloudfunctions2_function" "pubsub_handler_function" {
  name     = "pubsub-handler-function"
  location = "europe-central2"

  build_config {
    runtime     = "nodejs16"
    entry_point = "pubSubEventHandler"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket_function_sources.name
        object = google_storage_bucket_object.function_source_file.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }

  event_trigger {
    trigger_region = "europe-central2"
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.bucket_notification_topic.id
  }
}

output "function_uri" {
  value = google_cloudfunctions2_function.pubsub_handler_function.service_config[0].uri
}