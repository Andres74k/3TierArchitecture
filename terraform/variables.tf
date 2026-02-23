variable "prefix" {
    type = string
    description = "prefix for naming convention of resources"
}

variable "availability_zone" {
  type = list(string)
  description = "list of availability zones to use"
}

variable "ami"{
    description = "operating system for EC2"
    type = string
}

variable "region" {
    type = string
    description = "region in aws for resources"
}

variable "repo_link" {
  description = "Git repository URL"
  type        = string
}

variable "db_password" {
  description = "password for rds database"
  type = string
}

variable "db_name" {
    description = "database name"
    type = string
}

variable "db_username" {
  type = string
  description = "database username"
}
