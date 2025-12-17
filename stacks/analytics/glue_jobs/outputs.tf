######################################################################
# glue_jobs Module
######################################################################
output "job_names" {
  description = "Glue Job names"
  value       = { for job_key, job in module.glue_jobs : job_key => job.name }
}
