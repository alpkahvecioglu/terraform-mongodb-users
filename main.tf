resource "mongodb_db_role" "role" {
  for_each = { for k, v in var.db_roles : k => v if var.create_roles }
  name     = each.key
  database = each.value.database

  dynamic "privilege" {
    for_each = each.value.privileges
    content {
      db         = privilege.value["db"]
      collection = privilege.value["collection"]
      actions    = privilege.value["actions"]
    }
  }
}

resource "mongodb_db_role" "inherited_role" {
  for_each   = { for k, v in var.db_inherited_roles : k => v if var.create_roles }
  name       = each.key
  database   = each.value.database
  depends_on = [mongodb_db_role.role]

  dynamic "inherited_role" {
    for_each = each.value.inherited_roles
    content {
      db   = inherited_role.value["db"]
      // check if role name exists as roles to be created or is it built-in?
      role = contains(keys(var.db_roles), inherited_role.value["name"]) ? mongodb_db_role.role["${inherited_role.value["name"]}"].name : inherited_role.value["name"]
    }
  }

  dynamic "privilege" {
    for_each = each.value.privileges
    content {
      db         = privilege.value["db"]
      collection = privilege.value["collection"]
      actions    = privilege.value["actions"]
    }
  }
}

resource "mongodb_db_user" "user" {
  for_each      = nonsensitive({ for k, v in var.db_users : k => v if var.create_users })
  auth_database = each.value.auth_database
  name          = each.key
  password      = each.value.password

  dynamic "role" {
    for_each = each.value.roles
    content {
      role = role.value["name"]
      db   = role.value["db"]
    }
  }
}

resource "mongodb_db_user" "custom_role_user" {
  for_each      = nonsensitive({ for k, v in var.db_users_custom_role : k => v if var.create_users && var.create_roles })
  auth_database = each.value.auth_database
  name          = each.key
  password      = each.value.password
  depends_on    = [mongodb_db_role.role, mongodb_db_role.inherited_role]

  dynamic "role" {
    for_each = each.value.custom_roles
    content {
      role = mongodb_db_role.role["${role.value["name"]}"].name
      db   = role.value["db"]
    }
  }

  dynamic "role" {
    for_each = each.value.inherited_roles
    content {
      role = mongodb_db_role.inherited_role["${role.value["name"]}"].name
      db   = role.value["db"]
    }
  }

  dynamic "role" {
    for_each = each.value.roles
    content {
      role = role.value["name"]
      db   = role.value["db"]
    }
  }
}
