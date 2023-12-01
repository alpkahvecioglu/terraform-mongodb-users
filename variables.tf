variable "create_users" {
  type        = bool
  description = "Whether to create users on the DocDB instance"
  default     = false
}

variable "create_roles" {
  type        = bool
  description = "Whether to create roles on the DocDB instance"
  default     = false
}

variable "db_users" {
  type = map(object({
    auth_database = string
    password      = string
    roles = list(object({
      name = string
      db   = string
    }))
  }))
  default     = {}
  description = "A map of users to create"
  sensitive   = true
}

variable "db_users_custom_role" {
  type = map(object({
    auth_database = string
    password      = string
    custom_roles = list(object({
      name = string
      db   = string
    }))
    inherited_roles = optional(list(object({
      name = string
      db   = string
    })), [])
    roles = optional(list(object({
      name = string
      db   = string
    })), [])
  }))
  default     = {}
  description = "A map of users to create with custom roles"
  sensitive   = true
}

variable "db_roles" {
  type = map(object({
    database = optional(string, "admin")
    privileges = list(object({
      db         = string
      collection = optional(string, "")
      actions    = list(string)
    }))
  }))
  default     = {}
  description = "DB Roles"
}

variable "db_inherited_roles" {
  type = map(object({
    database = optional(string, "admin")
    privileges = optional(list(object({
      db         = string
      collection = optional(string, "")
      actions    = list(string)
    })), [])
    inherited_roles = list(object({
      name = string
      db   = string
    }))
  }))
  default     = {}
  description = "DB Roles that also inherits privileges from other roles"
}
