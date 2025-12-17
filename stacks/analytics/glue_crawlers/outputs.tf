######################################################################
# glue_crawlers Module
######################################################################
output "crawler_names" {
  description = "Glue crawler names"
  value       = { for crawler_key, crawler in module.glue_crawlers : crawler_key => crawler.name }
}
