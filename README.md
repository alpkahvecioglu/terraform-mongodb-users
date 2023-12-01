# Terraform MongoDB/DocumentDB Module for Users and Roles

This module is based on the [MongoDB provider](https://registry.terraform.io/providers/Kaginari/mongodb/)

You can check the provider documentation about how to configure the provider.

## Terragrunt
There is an example terragrunt configuration in the _examples_ directory. 

The provider settings in the example expect you to provide your credentials via the environment variables, MONGO_HOST, MONGO_USR, and MONGO_PWD. The provider will ask for the **username** and **password** if you don't configure these beforehand.

You also need to download your DocumentDB CA certificate and configure the path in your provider settings.

It is recommended that you use the **db_users** variable with *built-in roles* and the *db_users_custom_role* variable with roles that you manage from Terraform.

If you do not specify a database in the role you want to create **admin** DB will be used by default.

You should use the **inherited_roles** variable if you want to inherit the permissions of a role you manage in Terraform.

