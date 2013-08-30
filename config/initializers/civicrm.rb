CiviCrm.site_key = ENV['CIVICRM_SITE_KEY']
CiviCrm.api_base = "#{ ENV['CIVICRM_DOMAIN'] }#{ ENV['CIVICRM_API_BASE'] }"
CiviCrm.api_key  = ENV['CIVICRM_API_KEY']

CiviCrm.time_zone = ActiveSupport::TimeZone[ENV['CIVICRM_TIME_ZONE']]

CiviCrm.default_row_count = 50

CiviCrm.cache.config.cache_all_requests_for_entity('OptionValue', expires_in: 48.hours)
CiviCrm.cache.config.cache_all_requests_for_entity('CustomValue', expires_in: 48.hours)