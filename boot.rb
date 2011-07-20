require 'rubygems'
require 'bundler'
Bundler.require

ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift File.join(ROOT, 'app')
$:.unshift File.join(ROOT, 'lib')

Mongoid.load!(File.join(ROOT, 'etc', 'mongoid.yml'))

require 'poker_stars'
require 'main'
require 'async'
