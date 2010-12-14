--- 
name: kite
title: Kite
requires: 
- group: []

  name: sinatra
  version: 0+
- group: []

  name: aws-s3
  version: 0+
pom_verison: 1.0.0
manifest: 
- .ruby
- bin/kite
- lib/kite/application.rb
- lib/kite/assets/kite.gif
- lib/kite/cli.rb
- lib/kite/config.rb
- lib/kite/kernel.rb
- lib/kite/rack.rb
- lib/kite/rackup.rb
- lib/kite/server.rb
- lib/kite/storage_adapters/s3.rb
- lib/kite.rb
- LICENSE
- README.rdoc
- HISTORY
- VERSION
version: 0.1.0
authors: 
- Thomas Sawyer
