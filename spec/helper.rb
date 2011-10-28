require 'minitest/autorun'

require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'dm-sqlite-adapter'

require File.expand_path('../../lib/farmer_john', __FILE__)

# Models
require File.expand_path('../models/dm_post', __FILE__)
require File.expand_path('../models/dm_comment', __FILE__)

# setup repository
DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.auto_migrate!
