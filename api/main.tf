
terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
}

provider "google" {
    project = "grocery-api-380005"
}

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}


resource "google_cloud_run_service" "default" {
	name     = "grocery-api-dev"
    location = "us-central1"

    metadata {
      annotations = {
        "run.googleapis.com/client-name" = "terraform"
      }
    }

    template {
      spec {
        containers {
          image = "docker.io/pbivrell/grocery-api-dev:lastest"
        }
      }
    }

    depends_on = [google_project_service.run_api]

	traffic {
    	percent         = 100
    	latest_revision = true
	}
}

data "google_iam_policy" "noauth" {
	binding {
    	role = "roles/run.invoker"
    	members = ["allUsers"]
   	}
 }

resource "google_cloud_run_service_iam_policy" "noauth" {
   	location    = google_cloud_run_service.default.location
   	project     = google_cloud_run_service.default.project
   	service     = google_cloud_run_service.default.name

   	policy_data = data.google_iam_policy.noauth.policy_data
}

output "service_url" {
  value = google_cloud_run_service.default.status[0].url
}


resource "google_cloud_run_service" "default" {
  name     = "cloudrun-service"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello:latest" # Image to deploy
        # Sets a environment variable for instance connection name
        env {
          name  = "INSTANCE_CONNECTION_NAME"
          value = google_sql_database_instance.mysql_instance.connection_name
        }
        # Sets a secret environment variable for database user secret
        env {
          name = "DB_USER"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.dbuser.secret_id # secret name
              key  = "latest"                                      # secret version number or 'latest'
            }
          }
        }
        # Sets a secret environment variable for database password secret
        env {
          name = "DB_PASS"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.dbpass.secret_id # secret name
              key  = "latest"                                      # secret version number or 'latest'
            }
          }
        }
        # Sets a secret environment variable for database name secret
        env {
          name = "DB_NAME"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.dbname.secret_id # secret name
              key  = "latest"                                      # secret version number or 'latest'
            }
          }
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/client-name" = "terraform"
      }
    }
  }

  autogenerate_revision_name = true
  depends_on                 = [google_project_service.secretmanager_api, google_project_service.cloudrun_api, google_project_service.sqladmin_api]
}
