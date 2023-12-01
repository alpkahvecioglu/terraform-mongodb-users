include {
  path = find_in_parent_folders()
}

generate "provider-local" {
  path      = "provider-local.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "mongodb" {
  host = "127.0.0.1"
  port = "27017"
}
EOF
}

locals {
  create_users = true
  create_roles = true

  db_users = {
    user1 = {
      password = "test123!"
      auth_database = "mydb"
      roles = [
        { 
          name = "readAnyDatabase"
          db = "admin"
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
          db = "admin"
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

# where you keep the terraform module
terraform {
  source = "../../..//"
}

inputs = {
  db_users = local.db_users
  db_roles = local.db_roles
  db_inherited_roles = local.db_inherited_roles
  db_users_custom_role = local.db_users_custom_role
  create_users = local.create_users
  create_roles = local.create_roles
}

