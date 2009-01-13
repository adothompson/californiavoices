# Change globals to match the proper value for your site

DELETE_CONFIRM = "Are you sure you want to delete?\nThis can not be undone."
SEARCH_LIMIT = 25
SITE_NAME = 'California Voices'
SITE = RAILS_ENV == 'production' ? 'californiavoices.ucsc.edu' : 'localhost:3000'


MAILER_TO_ADDRESS = 'info@californiavoices.org'
MAILER_FROM_ADDRESS = 'The California Voices Team <info@californiavoices.org>'
REGISTRATION_RECIPIENTS = %W(info@californiavoices.org) #send an email to this list everytime someone signs up

# YOUTUBE_BASE_URL = "http://gdata.youtube.com/feeds/api/videos/"
