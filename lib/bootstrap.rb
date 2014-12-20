require "rubygems"
require 'bundler'

Bundler.require(:default)

require 'tempfile'
require 'fileutils'
require 'pathname'
require 'shellwords'

require_relative 'build'
require_relative 'network'
require_relative 'sshkey'
require_relative 'config'
require_relative 'command'
require_relative 'runner'
require_relative 'configurator'

ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))
TMP_PATH = File.join(ROOT_PATH, 'tmp')
LOGGER = Logger.new(STDOUT)
