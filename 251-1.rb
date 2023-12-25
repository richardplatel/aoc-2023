require 'ruby-graphviz'

GraphViz.parse( "25_sample.dot").output(:png => "sample.png", :use=>"fdp")
