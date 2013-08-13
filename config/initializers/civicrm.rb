CiviCrm.site_key = ENV['CIVICRM_SITE_KEY']
CiviCrm.api_base = ENV['CIVICRM_API_BASE']
CiviCrm.api_key  = ENV['CIVICRM_API_KEY']

CiviCrm.time_zone = ActiveSupport::TimeZone['Mountain Time (US & Canada)']

CiviCrm.cache.config.cache_all_requests_for_entity('OptionValue', expires_in: 1.day)
CiviCrm.cache.config.cache_all_requests_for_entity('CustomValue', expires_in: 1.day)