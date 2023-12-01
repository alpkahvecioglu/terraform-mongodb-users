include {
  path = find_in_parent_folders()
}

# Download your DocumentDB CA certificate and place it to the correct folder
generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "mongodb" {
  port = "27017"
  ssl = true
  direct = true
  certificate = file("${get_parent_terragrunt_dir()}/provider-config/documentdb/global-bundle.pem")
}
EOF
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  create_users = true
  create_roles = true

  db_users = {
    user1 = {
      password = "test123!"
      auth_database = "mydb"
      roles = [
        { 
          name = "readAnyDatabase"
          db = "mydb"
        }
      ]
    }
    user2 = {
      password = "test123!"
      auth_database = "mydb"
      roles = [
        { 
          name = "readAnyDatabase"
          db = "mydb2"
        },
        { 
          name = "readWriteAnyDatabase"
          db = "mydb"
        }
      ]
    }
  }

  db_users_custom_role = {
    custom_role_user = {
      password = "test123!"
      auth_database = "mydb"
      custom_roles = [
        { 
          name = "custom_role"
          db = "mydb"
        }
      ]
      // optional
      inherited_roles = [
        { 
          name = "custom_inherited_role"
          db = "mydb"
        }
      ]
      // optional
      roles = [
        { 
          name = "readWriteAnyDatabase"
          db = "mydb"
        }
      ]

    }
  }
 
  db_roles = {
    custom_role = {
      database = "mydb"
      privileges = [
        {
          db = "mydb"
          collection = "test"
          actions = ["listCollections"]
        }
      ]
    }
  }

  db_inherited_roles = {
    custom_inherited_role = {
      database = "mydb"
      inherited_roles = [
        {
          db = "mydb"
          name = "read"
        }
      ]

      // optional
      privileges = [
        {
          db = "mydb"
          collection = "test2"
          actions = ["listCollections"]
        }
      ]
    }
  }
}

terraform {
  source = "../../..//modules/terraform-aws-db-users"
}

inputs = {
  db_users = local.db_users
  db_roles = local.db_roles
  db_inherited_roles = local.db_inherited_roles
  db_users_custom_role = local.db_users_custom_role
  create_users = local.create_users
  create_roles = local.create_roles
  tags = local.common_vars.tags
}

