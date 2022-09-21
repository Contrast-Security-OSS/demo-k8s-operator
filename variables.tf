variable "initials" {
  description = "Enter your initials to include in URLs. Lowercase only!!!"
  default     = ""
}

variable "location" {
  description = "The Azure location where all resources in this example should be created, to find your nearest run `az account list-locations -o table`"
  default     = ""
}